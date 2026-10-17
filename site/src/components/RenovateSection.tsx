import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";
import { Reveal, ease } from "../lib/motion";
import { Icon } from "./Icon";
import { RENOVATE, RENOVATE_FEATURES, RENOVATE_STEPS, SITE } from "../content/site";
import { href } from "../lib/url";

function FloatingChip({ className, children, delay = 0 }: { className: string; children: React.ReactNode; delay?: number }) {
  const reduce = useReducedMotion();
  return (
    <motion.div
      aria-hidden="true"
      className={`absolute rounded-2xl border border-white/20 bg-ink/80 p-4 text-white shadow-2xl backdrop-blur-xl ${className}`}
      initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ duration: 0.8, ease, delay }}
      animate={reduce ? undefined : { y: [0, -8, 0] }}
    >
      {children}
    </motion.div>
  );
}

export function RenovateSection() {
  const ref = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], [-30, 30]);

  return (
    <section id="renovate" className="relative bg-white py-24 sm:py-32">
      <div className="mx-auto grid max-w-7xl gap-16 px-5 sm:px-8 lg:grid-cols-[0.9fr_1.1fr] lg:gap-20">
        {/* visuel */}
        <div ref={ref} className="relative lg:sticky lg:top-28 lg:self-start">
          <div className="relative aspect-[4/5] overflow-hidden rounded-[2rem] bg-marine">
            <motion.img
              src={href("/img/chantier-1100.webp")}
              srcSet={`${href("/img/chantier-640.webp")} 640w, ${href("/img/chantier-1100.webp")} 1100w`}
              sizes="(min-width:1024px) 40vw, 90vw"
              alt="Chantier de rénovation d'une maison de ville : étais métalliques et briques apparentes"
              width={1100} height={1467} loading="lazy"
              style={reduce ? undefined : { y, scale: 1.16 }}
              className="absolute inset-0 h-full w-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-ink/70 via-transparent to-transparent" aria-hidden="true" />
          </div>
          <FloatingChip className="-right-3 top-10 w-52 sm:-right-8" delay={0.2}>
            <p className="text-[0.65rem] uppercase tracking-widest text-mint">Lot · Toiture</p>
            <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-white/15"><div className="h-full w-[72%] rounded-full bg-mint" /></div>
            <p className="mt-2 text-xs text-white/70">Avancement du chantier</p>
          </FloatingChip>
          <FloatingChip className="-left-3 bottom-12 w-56 sm:-left-8" delay={0.4}>
            <p className="text-[0.65rem] uppercase tracking-widest text-amber">Dossier</p>
            <p className="mt-1 text-sm font-medium">Financement identifié</p>
            <p className="mt-1 text-xs text-white/70">Primes et prêts à taux 0 % applicables</p>
          </FloatingChip>
        </div>

        {/* contenu */}
        <div>
          <Reveal>
            <p className="text-xs font-medium uppercase tracking-[0.2em] text-emerald">L'application</p>
            <h2 className="font-display mt-4 text-4xl font-semibold leading-tight text-marine sm:text-5xl">
              Ren<span className="text-amber">0</span>vate, {RENOVATE.tagline.charAt(0).toLowerCase() + RENOVATE.tagline.slice(1)}
            </h2>
            <p className="mt-6 text-lg leading-relaxed text-slate">{RENOVATE.description}</p>
            <p className="mt-4 text-lg leading-relaxed text-slate">
              <strong className="text-marine">Primes Services passe exclusivement par Ren0vate</strong> : pour toute nouvelle demande, c'est l'application qui remplace
              l'analyse manuelle d'hier — avec la même expertise des subsides, disponible à tout moment.
            </p>
          </Reveal>

          <ul className="mt-12 grid gap-x-8 gap-y-8 sm:grid-cols-2">
            {RENOVATE_FEATURES.map((f, i) => (
              <Reveal as="li" key={f.title} delay={i * 0.6}>
                <span className="mb-3 inline-flex h-11 w-11 items-center justify-center rounded-xl bg-marine text-mint"><Icon name={f.icon} className="h-5 w-5" /></span>
                <h3 className="font-display text-xl font-semibold text-marine">{f.title}</h3>
                <p className="mt-1.5 text-[0.95rem] leading-relaxed text-slate">{f.text}</p>
              </Reveal>
            ))}
          </ul>

          <div className="mt-16 rounded-3xl bg-pearl p-8 sm:p-10">
            <h3 className="font-display text-2xl font-semibold text-marine">En quatre étapes</h3>
            <ol className="mt-8 space-y-7">
              {RENOVATE_STEPS.map((s, i) => (
                <Reveal as="li" key={s.n} delay={i * 0.5} className="flex gap-5">
                  <span className="font-display text-3xl font-semibold text-amber-deep">{s.n}</span>
                  <div>
                    <p className="font-semibold text-marine">{s.title}</p>
                    <p className="mt-0.5 text-slate">{s.text}</p>
                  </div>
                </Reveal>
              ))}
            </ol>
          </div>

          <Reveal className="mt-10 flex flex-col gap-3 sm:flex-row">
            <a href={RENOVATE.signup} className="btn-shine group relative inline-flex items-center justify-center gap-2 overflow-hidden rounded-full bg-marine px-7 py-4 font-semibold text-white transition hover:bg-ink">
              Créer mon projet sur Ren0vate <Icon name="arrow" className="h-5 w-5 transition group-hover:translate-x-1" />
            </a>
            <a href={RENOVATE.url} className="inline-flex items-center justify-center gap-2 rounded-full border border-line px-7 py-4 font-medium text-marine transition hover:border-marine">
              Découvrir Ren0vate
            </a>
          </Reveal>
          <p className="mt-4 text-sm text-slate">Le premier projet se gère gratuitement ; les fonctions professionnelles sont sur abonnement. Support Ren0vate : <a className="underline underline-offset-4 hover:text-marine" href={`mailto:${SITE.techEmail}`}>{SITE.techEmail}</a>.</p>
        </div>
      </div>
    </section>
  );
}
