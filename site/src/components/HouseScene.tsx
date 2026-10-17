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
 * Scène 3D temps réel, chargée à la demande dès l'affichage de la page.
 * Repli sur un plan fixe (sans animation) si mouvement réduit, WebGL absent ou erreur de chargement.
 */
export function HouseScene() {
  const reduce = useReducedMotion();
  const wrap = useRef<HTMLDivElement>(null);
  const inView = useInView(wrap, { margin: "100px" });
  const [Comp, setComp] = useState<ComponentType<House3DProps> | null>(null);
  const [ready, setReady] = useState(false);
  const [fallback, setFallback] = useState(false);
  const [phase, setPhase] = useState<Phase>("avant");

  useEffect(() => {
    if (reduce || !hasWebGL()) { setFallback(true); return; }
    let alive = true;
    import("./House3D")
      .then((m) => alive && setComp(() => m.House3D))
      .catch(() => alive && setFallback(true));
    return () => { alive = false; };
  }, [reduce]);

  const onReady = useCallback(() => setReady(true), []);
  const onPhase = useCallback((p: Phase) => setPhase(p), []);

  return (
    <div ref={wrap} className="relative aspect-[600/540] w-full" role="img" aria-label="Maison de ville en 3D : la chaleur s'échappe avant rénovation, puis isolation et panneaux solaires après">
      {fallback && <Blueprint animated={false} className="h-full w-full p-4" />}

      {!fallback && Comp && (
        <Boundary onError={() => setFallback(true)}>
          <motion.div className="absolute inset-0" initial={{ opacity: 0 }} animate={{ opacity: ready ? 1 : 0 }} transition={{ duration: 0.8 }}>
            <Comp onPhase={onPhase} onReady={onReady} active={inView} />
          </motion.div>
        </Boundary>
      )}

      {!fallback && Comp && ready && (
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
