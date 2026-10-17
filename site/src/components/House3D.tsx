// Scène 3D (Three.js / React Three Fiber) : une maison de ville qui se construit, perd de la chaleur,
// puis se rénove (isolation + panneaux solaires) en boucle. Chargée à la demande par HouseScene.
import { useEffect, useMemo, useRef } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import * as THREE from "three";

export type Phase = "avant" | "apres";

const W = 4; // largeur (x)
const D = 3; // profondeur (z)
const H = 2.6; // hauteur des murs
const RISE = 1.7; // hauteur du toit
const OVERHANG = 0.2;

const C = {
  line: "#dae4eb",
  wall: "#1f4468",
  roof: "#31577f",
  mint: "#4db885",
  emerald: "#2e7d52",
  amber: "#e8a020",
  hot: "#ff6a3d",
};

const clamp = (v: number, a = 0, b = 1) => Math.min(b, Math.max(a, v));
const smooth = (v: number) => {
  const t = clamp(v);
  return t * t * (3 - 2 * t);
};
const easeOutBack = (v: number) => {
  const t = clamp(v);
  const c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
};

function setAlpha(g: THREE.Object3D, k: number) {
  g.visible = k > 0.002;
  g.traverse((o) => {
    const mat = (o as THREE.Mesh).material as THREE.Material | undefined;
    if (!mat || Array.isArray(mat)) return;
    if (mat.userData.base === undefined) mat.userData.base = mat.opacity;
    mat.transparent = true;
    mat.opacity = (mat.userData.base as number) * k;
  });
}

/** Prisme du toit : triangle extrudé le long de z. */
function roofGeometry(scale = 1) {
  const hw = W / 2 + OVERHANG;
  const shape = new THREE.Shape();
  shape.moveTo(-hw * scale, 0);
  shape.lineTo(hw * scale, 0);
  shape.lineTo(0, RISE * scale);
  shape.closePath();
  const depth = (D + OVERHANG * 2) * scale;
  const g = new THREE.ExtrudeGeometry(shape, { depth, bevelEnabled: false });
  g.translate(0, 0, -depth / 2);
  return g;
}

// Toutes les surfaces translucides : depthWrite désactivé + renderOrder explicite, sinon une surface presque
// invisible (ex. la coque d'isolation qui s'efface) masque celles qui sont derrière selon l'angle de vue.
function Edges({ geometry, color, opacity = 1, order = 0 }: { geometry: THREE.BufferGeometry; color: string; opacity?: number; order?: number }) {
  const edges = useMemo(() => new THREE.EdgesGeometry(geometry, 20), [geometry]);
  return (
    <lineSegments geometry={edges} renderOrder={order + 0.5}>
      <lineBasicMaterial color={color} transparent opacity={opacity} depthWrite={false} />
    </lineSegments>
  );
}

function Solid({ geometry, color, opacity = 0.55, edge = C.line, edgeOpacity = 0.95, metal = false, order = 0 }: {
  geometry: THREE.BufferGeometry; color: string; opacity?: number; edge?: string; edgeOpacity?: number; metal?: boolean; order?: number;
}) {
  return (
    <>
      <mesh geometry={geometry} renderOrder={order}>
        <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.35} transparent opacity={opacity} depthWrite={false} roughness={metal ? 0.25 : 0.7} metalness={metal ? 0.8 : 0.1} side={THREE.DoubleSide} />
      </mesh>
      <Edges geometry={geometry} color={edge} opacity={edgeOpacity} order={order} />
    </>
  );
}

const SUN: [number, number, number] = [2.6, 5.2, -2.0];

const PANELS = (() => {
  // Panneaux posés sur le pan droit du toit (2 rangées x 3 colonnes).
  const slope = Math.hypot(W / 2 + OVERHANG, RISE);
  const dx = (W / 2 + OVERHANG) / slope, dy = -RISE / slope; // direction faîtage → égout
  const nx = RISE / slope, ny = (W / 2 + OVERHANG) / slope; // normale sortante
  const angle = Math.atan2(dy, dx);
  const list: { pos: [number, number, number]; angle: number; i: number }[] = [];
  let i = 0;
  for (const s of [0.85, 1.95]) for (const z of [-1.05, 0, 1.05]) {
    list.push({ pos: [dx * s + nx * 0.04, H + RISE + dy * s + ny * 0.04, z], angle, i: i++ });
  }
  return list;
})();

function Scene({ onPhase, onReady }: { onPhase: (p: Phase) => void; onReady: () => void }) {
  const camera = useThree((s) => s.camera);
  const root = useRef<THREE.Group>(null!);
  const walls = useRef<THREE.Group>(null!);
  const roof = useRef<THREE.Group>(null!);
  const details = useRef<THREE.Group>(null!);
  const shell = useRef<THREE.Group>(null!);
  const panels = useRef<THREE.Group>(null!);
  const sun = useRef<THREE.Mesh>(null!);
  const grid = useRef<THREE.GridHelper>(null!);
  const heat = useRef<THREE.Points>(null!);
  const sunLight = useRef<THREE.PointLight>(null!);
  const phaseRef = useRef<Phase>("avant");
  const yaw = useRef(-0.5);

  const wallGeo = useMemo(() => new THREE.BoxGeometry(W, H, D), []);
  const roofGeo = useMemo(() => roofGeometry(1), []);
  const shellWallGeo = useMemo(() => new THREE.BoxGeometry(W + 0.34, H + 0.3, D + 0.34), []);
  const shellRoofGeo = useMemo(() => roofGeometry(1.0), []);
  const chimneyGeo = useMemo(() => new THREE.BoxGeometry(0.38, 1.1, 0.38), []);
  const doorGeo = useMemo(() => new THREE.BoxGeometry(0.85, 1.55, 0.06), []);
  const winGeo = useMemo(() => new THREE.BoxGeometry(0.85, 0.95, 0.06), []);
  const panelGeo = useMemo(() => new THREE.BoxGeometry(1.0, 0.05, 0.95), []);

  // Particules de chaleur
  const N = 160;
  const heatData = useMemo(() => {
    const pos = new Float32Array(N * 3);
    const col = new Float32Array(N * 3);
    return { pos, col, vel: new Float32Array(N * 3), life: new Float32Array(N).fill(-1), max: new Float32Array(N).fill(1) };
  }, []);

  useEffect(() => {
    camera.position.set(9.8, 5.6, 11.6);
    camera.lookAt(0, 2.0, 0);
    onReady();
  }, [camera, onReady]);

  const spawn = (i: number) => {
    const { pos, vel, life, max } = heatData;
    const onRoof = Math.random() < 0.6;
    let x: number, y: number, z: number, ox = 0, oz = 0;
    if (onRoof) {
      x = (Math.random() * 2 - 1) * (W / 2);
      z = (Math.random() * 2 - 1) * (D / 2);
      y = H + RISE * (1 - Math.abs(x) / (W / 2 + OVERHANG)) + 0.05;
      ox = Math.sign(x) * 0.12;
    } else if (Math.random() < 0.5) {
      x = Math.random() < 0.5 ? -W / 2 - 0.05 : W / 2 + 0.05;
      y = 0.3 + Math.random() * (H - 0.4);
      z = (Math.random() * 2 - 1) * (D / 2);
      ox = Math.sign(x) * 0.35;
    } else {
      x = (Math.random() * 2 - 1) * (W / 2);
      y = 0.3 + Math.random() * (H - 0.4);
      z = Math.random() < 0.5 ? -D / 2 - 0.05 : D / 2 + 0.05;
      oz = Math.sign(z) * 0.35;
    }
    pos.set([x, y, z], i * 3);
    vel.set([ox + (Math.random() - 0.5) * 0.15, 0.45 + Math.random() * 0.5, oz + (Math.random() - 0.5) * 0.15], i * 3);
    life[i] = 0;
    max[i] = 1.8 + Math.random() * 1.6;
  };

  useFrame((state, dtRaw) => {
    const dt = Math.min(dtRaw, 0.05);
    const t = state.clock.elapsedTime;

    // --- Construction (une seule fois) ---
    const gridK = smooth(t / 1.0);
    (grid.current.material as THREE.Material).opacity = 0.55 * gridK;
    const w = easeOutBack((t - 0.3) / 1.2);
    walls.current.scale.y = Math.max(0.001, w);
    setAlpha(walls.current, smooth((t - 0.3) / 0.6));
    const r = smooth((t - 1.3) / 1.1);
    roof.current.position.y = H + (1 - r) * 3.2;
    setAlpha(roof.current, r);
    setAlpha(details.current, smooth((t - 2.2) / 0.9));

    // --- Cycle avant / après ---
    const L = 15;
    const c = t < 2.6 ? -1 : (t - 2.6) % L;
    let shellK = 0, panelsK = 0, spawnRate = 0;
    if (c >= 0) {
      if (c < 6) { spawnRate = smooth(c / 1.2); }
      else if (c < 8) { shellK = smooth((c - 6) / 2); spawnRate = 1 - shellK; }
      else if (c < 13) { shellK = 1; panelsK = 1; }
      else { const k = smooth((c - 13) / 1.6); shellK = 1 - k; panelsK = 1 - k; spawnRate = smooth((c - 14) / 1); }
    }
    const next: Phase = c >= 6 && c < 14 ? "apres" : "avant";
    if (next !== phaseRef.current) { phaseRef.current = next; onPhase(next); }

    shell.current.scale.setScalar(0.94 + 0.06 * shellK);
    setAlpha(shell.current, shellK);

    // panneaux : apparition échelonnée
    panels.current.children.forEach((p, i) => {
      const k = c >= 8 && c < 13.6 ? easeOutBack((c - 8.2 - i * 0.22) / 0.6) : panelsK;
      const s = clamp(k, 0, 1.15);
      p.scale.setScalar(Math.max(0.001, s));
      p.visible = s > 0.01;
      const m = (p.children[0] as THREE.Mesh).material as THREE.MeshStandardMaterial;
      m.emissiveIntensity = 0.25 + 0.35 * (0.5 + 0.5 * Math.sin(t * 2.2 + i));
    });
    // soleil
    const sunK = c >= 8 ? (c < 13 ? smooth((c - 8) / 1.2) : 1 - smooth((c - 13) / 1.4)) : 0;
    sun.current.scale.setScalar(Math.max(0.001, sunK));
    sun.current.position.set(SUN[0], SUN[1] + Math.sin(t * 0.6) * 0.12, SUN[2]);
    sunLight.current.intensity = 40 * sunK;

    // particules de chaleur
    const { pos, col, vel, life, max } = heatData;
    for (let i = 0; i < N; i++) {
      if (life[i] < 0 || life[i] >= max[i]) {
        life[i] = -1;
        if (spawnRate > 0 && Math.random() < spawnRate * dt * 28) spawn(i);
        col[i * 3] = col[i * 3 + 1] = col[i * 3 + 2] = 0;
        continue;
      }
      life[i] += dt;
      const k = life[i] / max[i];
      pos[i * 3] += vel[i * 3] * dt;
      pos[i * 3 + 1] += vel[i * 3 + 1] * dt;
      pos[i * 3 + 2] += vel[i * 3 + 2] * dt;
      const f = Math.sin(Math.PI * Math.min(1, k * 1.05)) ** 0.8; // fondu entrée/sortie (additif)
      const hot = new THREE.Color(C.hot).lerp(new THREE.Color(C.amber), k);
      col[i * 3] = hot.r * f; col[i * 3 + 1] = hot.g * f; col[i * 3 + 2] = hot.b * f;
    }
    const g = heat.current.geometry;
    (g.attributes.position as THREE.BufferAttribute).needsUpdate = true;
    (g.attributes.color as THREE.BufferAttribute).needsUpdate = true;

    // rotation : lente + parallaxe souris
    const target = -0.62 + Math.sin(t * 0.32) * 0.42 + state.pointer.x * 0.4;
    yaw.current += (target - yaw.current) * Math.min(1, dt * 3);
    root.current.rotation.y = yaw.current;
    root.current.rotation.x = THREE.MathUtils.lerp(root.current.rotation.x, -state.pointer.y * 0.08, Math.min(1, dt * 3));
  });

  return (
    <>
      <ambientLight intensity={1.1} />
      <directionalLight position={[6, 8, 9]} intensity={2.2} />
      <pointLight ref={sunLight} position={SUN} color={C.amber} intensity={0} distance={16} />
      <mesh ref={sun} position={SUN} scale={0.001}>
        <sphereGeometry args={[0.45, 24, 24]} />
        <meshBasicMaterial color={C.amber} />
      </mesh>
    <group ref={root} position={[0, -1.1, 0]}>

      <gridHelper ref={grid} args={[16, 32, "#3f6484", "#1f3b57"]}>
        <meshBasicMaterial transparent opacity={0} depthWrite={false} />
      </gridHelper>

      {/* murs */}
      <group ref={walls}>
        <group position={[0, H / 2, 0]}>
          <Solid geometry={wallGeo} color={C.wall} opacity={0.6} order={1} />
        </group>
      </group>
      {/* toit */}
      <group ref={roof} position={[0, H + 3.2, 0]}>
        <Solid geometry={roofGeo} color={C.roof} opacity={0.7} order={3} />
      </group>
      {/* détails : porte, fenêtres, lucarne, cheminée */}
      <group ref={details}>
        <group position={[0, 0.78, D / 2 + 0.03]}><Solid geometry={doorGeo} color="#0f2438" opacity={0.95} edge={C.amber} order={5} /></group>
        {[-1.2, 1.2].map((x) => (
          <group key={x} position={[x, 1.65, D / 2 + 0.03]}><Solid geometry={winGeo} color="#2a5a82" opacity={0.85} order={5} /></group>
        ))}
        <mesh position={[0, H + 0.62, D / 2 + OVERHANG + 0.03]} renderOrder={5}>
          <torusGeometry args={[0.24, 0.025, 8, 32]} />
          <meshBasicMaterial color={C.line} transparent opacity={0.95} depthWrite={false} />
        </mesh>
        <group position={[-0.95, H + 1.3, 0.55]}><Solid geometry={chimneyGeo} color={C.roof} opacity={0.9} order={5} /></group>
      </group>
      {/* sur-isolation (coque émeraude) */}
      <group ref={shell} position={[0, 0, 0]}>
        <group position={[0, (H + 0.3) / 2 - 0.15, 0]}>
          <Solid geometry={shellWallGeo} color={C.emerald} opacity={0.16} edge={C.mint} edgeOpacity={0.8} order={7} />
        </group>
        <group position={[0, H + 0.12, 0]} scale={[1.06, 1.12, 1.06]}>
          <Solid geometry={shellRoofGeo} color={C.emerald} opacity={0.14} edge={C.mint} edgeOpacity={0.8} order={7} />
        </group>
      </group>
      {/* panneaux solaires */}
      <group ref={panels}>
        {PANELS.map((p) => (
          <group key={p.i} position={p.pos} rotation={[0, 0, p.angle]}>
            <mesh geometry={panelGeo}>
              <meshStandardMaterial color="#0a1f38" metalness={0.85} roughness={0.2} emissive="#3b6fa8" emissiveIntensity={0.3} />
            </mesh>
            <Edges geometry={panelGeo} color={C.amber} order={9} />
            <mesh position={[0, 0.032, 0]} rotation={[-Math.PI / 2, 0, 0]}>
              <planeGeometry args={[0.96, 0.9, 3, 3]} />
              <meshBasicMaterial color={C.amber} wireframe transparent opacity={0.55} depthWrite={false} />
            </mesh>
          </group>
        ))}
      </group>
      {/* déperditions de chaleur */}
      <points ref={heat} frustumCulled={false}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" args={[heatData.pos, 3]} />
          <bufferAttribute attach="attributes-color" args={[heatData.col, 3]} />
        </bufferGeometry>
        <pointsMaterial
          size={0.16} vertexColors transparent depthWrite={false} sizeAttenuation
          blending={THREE.CustomBlending} blendEquation={THREE.AddEquation}
          blendSrc={THREE.OneFactor} blendDst={THREE.OneFactor}
          blendSrcAlpha={THREE.ZeroFactor} blendDstAlpha={THREE.OneFactor}
        />
      </points>
    </group>
    </>
  );
}

export function House3D({ onPhase, onReady, active }: { onPhase: (p: Phase) => void; onReady: () => void; active: boolean }) {
  return (
    <Canvas
      dpr={[1, 1.75]}
      frameloop={active ? "always" : "never"}
      camera={{ fov: 30, near: 0.1, far: 60 }}
      gl={{ antialias: true, alpha: true, powerPreference: "high-performance" }}
      aria-hidden="true"
    >
      <Scene onPhase={onPhase} onReady={onReady} />
    </Canvas>
  );
}

export default House3D;
