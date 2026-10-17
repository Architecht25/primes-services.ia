import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";
import { HouseScene } from "./HouseScene";
import { Icon } from "./Icon";
import { Counter, ease } from "../lib/motion";
import { RENOVATE, STATS } from "../content/site";
import { href } from "../lib/url";

const TITLE = ["Primes,", "subsides", "et", "prêts", "à", "taux", "0 %", ":", "tout", "se", "gère", "dans"];

export function Hero() {
  const ref = useRef<HTMLElement>(null);
  const reduce = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] });
  const yBlue = useTransform(scrollYProgress, [0, 1], [0, 140]);
  const yPhoto = useTransform(scrollYProgress, [0, 1], [0, 80]);
  const fade = useTransform(scrollYProgress, [0, 0.8], [1, 0]);

  return (
    <section ref={ref} className="blueprint-grid grain relative isolate overflow-hidden bg-ink pt-32 pb-24 text-white sm:pt-40">
      {/* photo de chantier en filigrane */}
      <motion.div style={{ y: reduce ? 0 : yPhoto }} className="pointer-events-none absolute inset-y-0 right-0 -z-10 w-full opacity-[0.18] lg:w-3/5" aria-hidden="true">
        <img
          src={href("/img/chantier-1100.webp")}
          srcSet={`${href("/img/chantier-640.webp")} 640w, ${href("/img/chantier-1100.webp")} 1100w`}
          sizes="(min-width:1024px) 60vw, 100vw"
          alt=""
          width={1100}
          height={1467}
          fetchPriority="high"
          className="h-full w-full object-cover object-center [mask-image:linear-gradient(to_left,black_30%,transparent)]"
        />
      </motion.div>
      <div className="pointer-events-none absolute -left-40 top-20 -z-10 h-[34rem] w-[34rem] rounded-full bg-emerald/25 blur-[120px]" aria-hidden="true" />
      <div className="pointer-events-none absolute right-0 bottom-0 -z-10 h-[28rem] w-[28rem] rounded-full bg-marine/60 blur-[120px]" aria-hidden="true" />

      <motion.div style={{ opacity: reduce ? 1 : fade }} className="mx-auto grid max-w-7xl items-center gap-12 px-5 sm:px-8 lg:grid-cols-[1.15fr_1fr]">
        <div>
          <motion.p
            initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, ease }}
            className="mb-6 inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-4 py-1.5 text-xs font-medium uppercase tracking-[0.18em] text-mint backdrop-blur"
          >
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-mint" /> Rénovation · Belgique · depuis 2010
          </motion.p>

          <h1 className="font-display text-[2.6rem] font-semibold leading-[1.04] sm:text-6xl lg:text-[4.4rem]">
            {TITLE.map((w, i) => (
              <span key={i} className="inline-block overflow-hidden align-bottom">
                <motion.span
                  className="inline-block"
                  initial={{ y: "105%", rotate: 4 }}
                  animate={{ y: 0, rotate: 0 }}
                  transition={{ duration: 0.9, ease, delay: 0.15 + i * 0.055 }}
                >
                  {w}
                </motion.span>
              </span>
            )).flatMap((el, i) => [el, " "])}
            <span className="inline-block overflow-hidden align-bottom">
              <motion.span
                className="inline-block bg-gradient-to-r from-amber via-amber-soft to-amber bg-clip-text text-transparent"
                initial={{ y: "105%", rotate: 4 }} animate={{ y: 0, rotate: 0 }} transition={{ duration: 0.9, ease, delay: 0.85 }}
              >
                Ren0vate.
              </motion.span>
            </span>
          </h1>

          <motion.p
            initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8, ease, delay: 1.05 }}
            className="mt-8 max-w-xl text-lg leading-relaxed text-white/75"
          >
            Primes Services accompagne depuis plus de 15 ans les propriétaires en <strong className="font-semibold text-white">Wallonie, Flandre et Bruxelles</strong>.
            Toute notre expertise des subsides vit aujourd'hui dans <strong className="font-semibold text-white">Ren0vate</strong>, l'application de gestion de chantier et de subsides.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8, ease, delay: 1.2 }}
            className="mt-10 flex flex-col gap-3 sm:flex-row"
          >
            <a href={RENOVATE.url} className="btn-shine group relative inline-flex items-center justify-center gap-2 overflow-hidden rounded-full bg-amber px-7 py-4 font-semibold text-ink shadow-[0_10px_40px_-10px_rgba(232,160,32,0.7)] transition hover:bg-amber-soft">
              Ouvrir Ren0vate <Icon name="arrow" className="h-5 w-5 transition group-hover:translate-x-1" />
            </a>
            <a href={href("/#regions")} className="inline-flex items-center justify-center gap-2 rounded-full border border-white/20 px-7 py-4 font-medium text-white transition hover:border-white/50 hover:bg-white/5">
              Voir les aides par région
            </a>
          </motion.div>
        </div>

        <motion.div style={{ y: reduce ? 0 : yBlue }} className="relative mx-auto w-full max-w-lg">
          <div className="absolute inset-0 -z-10 rounded-[2rem] border border-white/10 bg-white/[0.03] backdrop-blur-sm" aria-hidden="true" />
          <HouseScene />
        </motion.div>
      </motion.div>

      <dl className="mx-auto mt-20 grid max-w-7xl gap-px overflow-hidden px-5 sm:px-8 md:grid-cols-3">
        {STATS.map((s, i) => (
          <motion.div
            key={s.label}
            initial={{ opacity: 0, y: 24 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}
            transition={{ duration: 0.8, ease, delay: i * 0.12 }}
            className="flex flex-col-reverse justify-end border-t border-white/15 py-6 md:pr-8"
          >
            <dt className="mt-1 text-sm text-white/60">{s.label}</dt>
            <dd className="font-display text-5xl font-semibold text-amber sm:text-6xl">
              <Counter value={s.value} prefix={s.prefix} suffix={s.suffix} />
            </dd>
          </motion.div>
        ))}
      </dl>
    </section>
  );
}
