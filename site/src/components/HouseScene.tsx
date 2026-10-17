import { Component, useCallback, useEffect, useRef, useState, type ComponentType, type ReactNode } from "react";
import { AnimatePresence, motion, useInView, useReducedMotion } from "framer-motion";
import { Blueprint } from "./Blueprint";
import type { Phase } from "./House3D";

type House3DProps = { onPhase: (p: Phase) => void; onReady: () => void; active: boolean };

class Boundary extends Component<{ children: ReactNode; onError: () => void }, { failed: boolean }> {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  componentDidCatch() { this.props.onError(); }
  render() { return this.state.failed ? null : this.props.children; }
}

function hasWebGL() {
  try {
    const c = document.createElement("canvas");
    return !!(c.getContext("webgl2") || c.getContext("webgl"));
  } catch { return false; }
}

const LABEL: Record<Phase, string> = {
  avant: "Avant : la chaleur s'échappe",
  apres: "Après : isolation + solaire",
};

/**
 * Plan SVG (prérendu, toujours présent) → scène 3D temps réel chargée à la demande.
 * Repli sur le plan SVG si mouvement réduit, WebGL absent ou erreur de chargement.
 */
export function HouseScene() {
  const reduce = useReducedMotion();
  const wrap = useRef<HTMLDivElement>(null);
  const inView = useInView(wrap, { margin: "100px" });
  const [Comp, setComp] = useState<ComponentType<House3DProps> | null>(null);
  const [ready, setReady] = useState(false);
  const [failed, setFailed] = useState(false);
  const [phase, setPhase] = useState<Phase>("avant");

  useEffect(() => {
    if (reduce || !hasWebGL()) return;
    let alive = true;
    const t0 = performance.now();
    import("./House3D")
      .then((m) => {
        // laisse le plan se dessiner (~3,5 s) avant de passer en 3D
        const wait = Math.max(0, 3500 - (performance.now() - t0));
        window.setTimeout(() => alive && setComp(() => m.House3D), wait);
      })
      .catch(() => alive && setFailed(true));
    return () => { alive = false; };
  }, [reduce]);

  const onReady = useCallback(() => setReady(true), []);
  const onPhase = useCallback((p: Phase) => setPhase(p), []);
  const show3d = !!Comp && !failed;

  return (
    <div ref={wrap} className="relative aspect-[600/540] w-full" role="img" aria-label="Maison de ville en 3D : la chaleur s'échappe avant rénovation, puis isolation et panneaux solaires après">
      <div className={`absolute inset-0 transition-opacity duration-1000 ${show3d && ready ? "opacity-0" : "opacity-100"}`}>
        <Blueprint className="h-full w-full p-4" />
      </div>

      {show3d && Comp && (
        <Boundary onError={() => setFailed(true)}>
          <motion.div className="absolute inset-0" initial={{ opacity: 0 }} animate={{ opacity: ready ? 1 : 0 }} transition={{ duration: 1 }}>
            <Comp onPhase={onPhase} onReady={onReady} active={inView} />
          </motion.div>
        </Boundary>
      )}

      {show3d && ready && (
        <div aria-hidden="true" className="pointer-events-none absolute inset-x-0 bottom-3 flex justify-center">
          <AnimatePresence mode="wait">
            <motion.span
              key={phase}
              initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.4 }}
              className={`rounded-full border px-4 py-1.5 text-xs font-medium uppercase tracking-[0.14em] backdrop-blur ${
                phase === "avant" ? "border-amber/40 bg-amber/10 text-amber-soft" : "border-mint/40 bg-mint/10 text-mint"
              }`}
            >
              {LABEL[phase]}
            </motion.span>
          </AnimatePresence>
        </div>
      )}
    </div>
  );
}
