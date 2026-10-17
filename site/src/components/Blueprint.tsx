import { motion, useReducedMotion } from "framer-motion";
import { ease } from "../lib/motion";

/** Élévation d'une maison de ville belge : trait, isolation, panneaux solaires. Animée, ou fixe (`animated={false}`) pour le repli. */
export function Blueprint({ className = "", animated = true }: { className?: string; animated?: boolean }) {
  const reduce = useReducedMotion() || !animated;
  const draw = (delay: number, duration = 1.4) => ({
    initial: reduce ? false : { pathLength: 0, opacity: 0 },
    animate: { pathLength: 1, opacity: 1 },
    transition: { duration, delay, ease },
  });
  const common = { fill: "none", strokeLinecap: "round" as const, strokeLinejoin: "round" as const };

  return (
    <svg viewBox="0 0 600 540" className={className} role="img" aria-label="Plan d'architecte d'une maison de ville belge en cours de rénovation énergétique">
      {/* sol + corps de bâtiment */}
      <motion.path d="M20 470H580" stroke="#8ca8be" strokeWidth="1.5" {...common} {...draw(0.1, 1)} />
      <motion.path d="M120 470V262H480V470" stroke="#dae4eb" strokeWidth="2.5" {...common} {...draw(0.3)} />
      {/* toiture */}
      <motion.path d="M88 262L300 112L512 262" stroke="#dae4eb" strokeWidth="2.5" {...common} {...draw(0.7)} />
      {/* sur-isolation (tracé émeraude en pointillés) */}
      <motion.path d="M104 262L300 124L496 262" stroke="#4db885" strokeWidth="2" strokeDasharray="6 7" {...common} {...draw(1.6, 1.6)} />
      <motion.path d="M134 470V276H466V470" stroke="#4db885" strokeWidth="1.5" strokeDasharray="6 7" {...common} {...draw(2, 1.6)} />
      {/* cheminée */}
      <motion.path d="M398 170V118H430V196" stroke="#dae4eb" strokeWidth="2.5" {...common} {...draw(1.1, 0.9)} />
      {/* lucarne ronde */}
      <motion.circle cx="300" cy="206" r="24" stroke="#dae4eb" strokeWidth="2" {...common} {...draw(1.3, 0.9)} />
      <motion.path d="M300 182V230M276 206H324" stroke="#8ca8be" strokeWidth="1.2" {...common} {...draw(1.5, 0.7)} />
      {/* fenêtres */}
      {[[158, 304], [372, 304]].map(([x, y], i) => (
        <g key={i}>
          <motion.rect x={x} y={y} width="70" height="86" rx="2" stroke="#dae4eb" strokeWidth="2" {...common} {...draw(1.5 + i * 0.15, 1)} />
          <motion.path d={`M${x + 35} ${y}V${y + 86}M${x} ${y + 43}H${x + 70}`} stroke="#8ca8be" strokeWidth="1.2" {...common} {...draw(1.8 + i * 0.15, 0.8)} />
        </g>
      ))}
      {/* porte cintrée */}
      <motion.path d="M268 470V402a32 32 0 0 1 64 0V470" stroke="#dae4eb" strokeWidth="2.5" {...common} {...draw(1.9, 1)} />
      <motion.path d="M300 370V470" stroke="#8ca8be" strokeWidth="1.2" {...common} {...draw(2.3, 0.6)} />
      {/* panneaux solaires sur le pan gauche */}
      <motion.path d="M245.3 147.1L118.1 237.1L108.2 223.2L235.4 133.2Z" stroke="#e8a020" strokeWidth="2" fill="rgba(232,160,32,0.14)" strokeLinejoin="round" {...draw(2.6, 1.2)} />
      <motion.path d="M213.5 169.6L203.6 155.7M181.7 192.1L171.8 178.2M149.9 214.6L140 200.7" stroke="#e8a020" strokeWidth="1.2" {...common} {...draw(3.1, 0.8)} />
      {/* cotes */}
      <motion.path d="M120 502H480M120 494V510M480 494V510" stroke="#5a829e" strokeWidth="1.2" {...common} {...draw(3, 1)} />
      <motion.path d="M540 262V470M532 262H548M532 470H548" stroke="#5a829e" strokeWidth="1.2" {...common} {...draw(3.1, 1)} />
      <motion.text x="300" y="526" textAnchor="middle" fill="#8ca8be" fontSize="13" letterSpacing="3" initial={reduce ? false : { opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 3.6, duration: 0.8 }}>
        PEB ↑ · ISOLATION · SOLAIRE
      </motion.text>
      {/* repères de coupe */}
      <motion.g initial={reduce ? false : { opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 3.8, duration: 0.8 }} fill="#4db885" fontSize="11" letterSpacing="2">
        <text x="40" y="150">A</text>
        <path d="M32 156h22" stroke="#4db885" strokeWidth="1" />
        <text x="540" y="150">A</text>
      </motion.g>
    </svg>
  );
}
