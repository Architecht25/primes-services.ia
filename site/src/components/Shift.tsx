import { motion } from "framer-motion";
import { Reveal, ease } from "../lib/motion";

type Ev = { when: string; where: string; text: string; tone: string; state: "now" | "next" };

const EVENTS: Ev[] = [
  { when: "En vigueur depuis le 1er mars 2026", where: "Flandre", text: "Mijn VerbouwLening jusqu'à 60 000 € à 0 – 1,5 % et Mijn VerbouwPremie, avec pompe à chaleur seule pour les catégories 1 et 2.", tone: "text-amber", state: "now" },
  { when: "En vigueur depuis le 1er octobre 2026", where: "Wallonie", text: "Rénopack (0 %, 15 à 50 % du capital non remboursé) et Rénoprêt, jusqu'à 75 000 € pour une maison.", tone: "text-mint", state: "now" },
  { when: "Printemps 2027", where: "Bruxelles", text: "Prêts énergie et rénovation à taux 0 % annoncés par le gouvernement bruxellois, modalités à publier.", tone: "text-[#7aa5c7]", state: "next" },
  { when: "1er janvier 2028", where: "Wallonie", text: "L'Agence wallonne de l'Habitation pilote le dispositif, avec agrément des opérateurs.", tone: "text-mint", state: "next" },
];

export function Shift() {
  return (
    <section id="changement" className="relative overflow-hidden bg-ink py-24 text-white sm:py-32">
      <div className="blueprint-grid absolute inset-0 opacity-60" aria-hidden="true" />
      <div className="relative mx-auto max-w-7xl px-5 sm:px-8">
        <Reveal>
          <p className="text-xs font-medium uppercase tracking-[0.2em] text-mint">Aujourd'hui et à venir</p>
          <h2 className="font-display mt-4 max-w-3xl text-4xl font-semibold leading-tight sm:text-5xl">
            La rénovation se finance désormais par <span className="text-amber">des prêts à taux 0 %</span> ou réduit.
          </h2>
          <p className="mt-6 max-w-2xl text-lg leading-relaxed text-white/70">
            Les trois régions belges orientent leur soutien vers des prêts à taux 0 % ou réduit, souvent assortis d'un audit énergétique préalable.
            Mieux vaut piloter l'ensemble — financement, devis, chantier — depuis un seul outil.
          </p>
        </Reveal>

        <ol className="relative mt-16 grid gap-10 md:grid-cols-2 lg:grid-cols-4 lg:gap-8">
          <motion.div
            aria-hidden="true"
            className="absolute left-0 right-0 top-[0.45rem] hidden h-px origin-left bg-gradient-to-r from-amber via-mint to-[#7aa5c7] lg:block"
            initial={{ scaleX: 0 }} whileInView={{ scaleX: 1 }} viewport={{ once: true }} transition={{ duration: 1.6, ease }}
          />
          {EVENTS.map((e, i) => (
            <Reveal as="li" key={e.where + e.when} delay={i}>
              <span className={`relative z-10 mb-6 block h-3 w-3 rounded-full bg-current ${e.tone} shadow-[0_0_0_6px_rgba(255,255,255,0.06)] ${e.state === "next" ? "opacity-60 ring-1 ring-current ring-offset-2 ring-offset-ink" : ""}`} />
              <p className={`text-sm font-semibold uppercase tracking-wider ${e.tone}`}>{e.when}</p>
              <h3 className="font-display mt-2 text-2xl font-semibold">{e.where}</h3>
              <p className="mt-2 max-w-xs leading-relaxed text-white/65">{e.text}</p>
            </Reveal>
          ))}
        </ol>
      </div>
    </section>
  );
}
