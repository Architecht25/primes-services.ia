import { motion } from "framer-motion";
import { Reveal, ease } from "../lib/motion";
import { Icon } from "./Icon";
import { Faq } from "./Sections";
import { KIND_LABEL, REGIONS, REGION_ORDER, RENOVATE, SITE, type Region } from "../content/site";
import { href, regionPath } from "../lib/url";

export function RegionPage({ r }: { r: Region }) {
  return (
    <>
      <section className={`region-${r.accent} blueprint-grid grain relative isolate overflow-hidden bg-ink pt-36 pb-20 text-white sm:pt-44`}>
        <div className="pointer-events-none absolute -right-32 top-10 -z-10 h-[30rem] w-[30rem] rounded-full blur-[130px]" style={{ background: "var(--r)", opacity: 0.22 }} aria-hidden="true" />
        <div className="mx-auto max-w-5xl px-5 sm:px-8">
          <motion.nav aria-label="Fil d'Ariane" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-sm text-white/55">
            <a className="hover:text-white" href={href("/")}>Accueil</a> <span aria-hidden="true">/</span> <a className="hover:text-white" href={href("/#regions")}>Aides par région</a> <span aria-hidden="true">/</span> <span className="text-white/85">{r.name}</span>
          </motion.nav>
          <motion.p initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, ease }} className="mt-8 inline-block rounded-full border border-white/15 bg-white/5 px-4 py-1.5 text-xs font-medium uppercase tracking-[0.16em]" style={{ color: "var(--r)" }}>
            {r.status}
          </motion.p>
          <motion.h1 initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.9, ease, delay: 0.1 }} className="font-display mt-6 text-4xl font-semibold leading-[1.05] sm:text-6xl">
            Primes et prêts à taux 0 % en {r.name === "Bruxelles-Capitale" ? "Région de Bruxelles-Capitale" : r.name}
          </motion.h1>
          <motion.p initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.9, ease, delay: 0.25 }} className="mt-6 max-w-3xl text-lg leading-relaxed text-white/75">
            {r.summary}
          </motion.p>
          <p className="mt-4 text-sm text-white/50">Vérifié le {SITE.verifiedLabel}</p>
        </div>
      </section>

      <section className={`region-${r.accent} bg-pearl py-20 sm:py-24`}>
        <div className="mx-auto max-w-5xl px-5 sm:px-8">
          <Reveal><h2 className="font-display text-3xl font-semibold text-marine sm:text-4xl">Ce qui reste disponible</h2></Reveal>
          <ul className="mt-10 grid gap-5 md:grid-cols-2">
            {r.schemes.map((s, i) => (
              <Reveal as="li" key={s.name} delay={i * 0.6} className="relative overflow-hidden rounded-3xl border border-line bg-white p-7">
                <span className="absolute inset-y-0 left-0 w-1.5" style={{ background: "var(--r)" }} aria-hidden="true" />
                <p className="text-[0.7rem] font-semibold uppercase tracking-widest text-slate">{KIND_LABEL[s.kind]}</p>
                <h3 className="font-display mt-1 text-2xl font-semibold text-marine">{s.name}</h3>
                <p className="mt-3 leading-relaxed text-slate">{s.text}</p>
              </Reveal>
            ))}
          </ul>

          <div className="mt-10 grid gap-5 md:grid-cols-2">
            <Reveal className="rounded-3xl border border-line bg-white p-7">
              <h3 className="font-display text-2xl font-semibold text-marine">Conditions à connaître</h3>
              <ul className="mt-4 list-disc space-y-2.5 pl-5 leading-relaxed text-slate">
                {r.conditions.map((c) => <li key={c}>{c}</li>)}
              </ul>
            </Reveal>
            <Reveal delay={1} className="rounded-3xl border border-amber/40 bg-amber/10 p-7">
              <h3 className="font-display text-2xl font-semibold text-marine">À venir</h3>
              <ul className="mt-4 list-disc space-y-2.5 pl-5 leading-relaxed text-slate">
                {r.upcoming.map((c) => <li key={c}>{c}</li>)}
              </ul>
            </Reveal>
          </div>
          <p className="mt-6 text-sm leading-relaxed text-slate"><strong className="text-marine">Sources consultées :</strong> {r.sourcesChecked}</p>
        </div>
      </section>

      <section className="bg-marine py-20 text-white">
        <div className="mx-auto flex max-w-5xl flex-col items-start justify-between gap-8 px-5 sm:px-8 md:flex-row md:items-center">
          <Reveal>
            <h2 className="font-display text-3xl font-semibold sm:text-4xl">Calculez votre financement dans Ren0vate</h2>
            <p className="mt-3 max-w-xl text-white/70">Indiquez votre région, vos revenus et vos travaux : Ren0vate identifie les aides applicables à votre cas et pilote le chantier jusqu'au dépôt des dossiers.</p>
          </Reveal>
          <a href={RENOVATE.signup} className="btn-shine group relative inline-flex shrink-0 items-center gap-2 overflow-hidden rounded-full bg-amber px-7 py-4 font-semibold text-ink transition hover:bg-amber-soft">
            Ouvrir Ren0vate <Icon name="arrow" className="h-5 w-5 transition group-hover:translate-x-1" />
          </a>
        </div>
      </section>

      <section className="bg-white py-20">
        <div className="mx-auto grid max-w-5xl gap-12 px-5 sm:px-8 md:grid-cols-2">
          <Reveal>
            <h2 className="font-display text-3xl font-semibold text-marine">Sources officielles</h2>
            <p className="mt-3 text-slate">{r.authority.name}{r.authority.phone ? ` – ${r.authority.phone}` : ""}</p>
            <ul className="mt-5 space-y-2">
              {r.officialLinks.map((l) => (
                <li key={l.url}><a className="inline-flex items-center gap-1.5 font-medium text-marine underline decoration-line underline-offset-4 hover:decoration-marine" href={l.url} rel="noopener">{l.label}<Icon name="arrowUpRight" className="h-4 w-4" /></a></li>
              ))}
            </ul>
          </Reveal>
          <Reveal delay={1}>
            <h2 className="font-display text-3xl font-semibold text-marine">Villes principales</h2>
            <p className="mt-3 text-slate">Les dispositifs régionaux s'appliquent partout en {r.name} ; les primes communales varient selon la commune.</p>
            <ul className="mt-5 flex flex-wrap gap-2">
              {r.cities.map((c) => <li key={c} className="rounded-full border border-line bg-pearl px-4 py-1.5 text-sm text-marine">{c}</li>)}
            </ul>
          </Reveal>
        </div>
      </section>

      <Faq items={r.faq} title={`Questions sur les aides – ${r.name}`} id="faq" />

      <section className="bg-white py-16">
        <div className="mx-auto max-w-5xl px-5 sm:px-8">
          <p className="text-sm font-semibold uppercase tracking-widest text-slate">Autres régions</p>
          <div className="mt-4 flex flex-wrap gap-3">
            {REGION_ORDER.filter((s) => s !== r.slug).map((s) => (
              <a key={s} href={href(regionPath(s))} className="inline-flex items-center gap-2 rounded-full border border-line px-6 py-3 font-medium text-marine transition hover:border-marine">
                {REGIONS[s].name} <Icon name="arrow" className="h-4 w-4" />
              </a>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
