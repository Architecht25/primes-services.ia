import { motion, useInView, useMotionValue, animate, useReducedMotion, type Variants } from "framer-motion";
import { useEffect, useRef, type ReactNode } from "react";

export const ease = [0.22, 1, 0.36, 1] as const;

export const fadeUp: Variants = {
  hidden: { opacity: 0, y: 28 },
  show: (i: number = 0) => ({ opacity: 1, y: 0, transition: { duration: 0.8, ease, delay: i * 0.08 } }),
};

export function Reveal({
  children, className, delay = 0, as = "div",
}: { children: ReactNode; className?: string; delay?: number; as?: "div" | "li" | "section" | "article" }) {
  const M = motion[as] as typeof motion.div;
  return (
    <M
      className={className}
      variants={fadeUp}
      custom={delay}
      initial="hidden"
      whileInView="show"
      viewport={{ once: true, margin: "0px 0px -12% 0px" }}
    >
      {children}
    </M>
  );
}

/** Compteur animé. Le HTML prérendu contient la valeur finale (lisible par les crawlers). */
export function Counter({ value, prefix = "", suffix = "" }: { value: number; prefix?: string; suffix?: string }) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: "0px 0px -10% 0px" });
  const reduce = useReducedMotion();
  const mv = useMotionValue(0);
  const fmt = (n: number) => `${prefix}${Math.round(n).toLocaleString("fr-BE")}${suffix}`;

  useEffect(() => {
    if (!inView || reduce) return;
    const el = ref.current;
    if (!el) return;
    el.textContent = fmt(0);
    const unsub = mv.on("change", (v) => { el.textContent = fmt(v); });
    const controls = animate(mv, value, { duration: 2.2, ease });
    return () => { unsub(); controls.stop(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inView, reduce, value]);

  return <span ref={ref}>{fmt(value)}</span>;
}
