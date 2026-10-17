import { motion } from "framer-motion";
import { Reveal } from "../lib/motion";
import { Icon } from "./Icon";
import { KIND_LABEL, REGIONS, REGION_ORDER, SITE, type Region } from "../content/site";
import { href, regionPath } from "../lib/url";

export function RegionCard({ r, index = 0 }: { r: Region; index?: number }) {
  return (
    <Reveal as="article" delay={index} className={`region-${r.accent}`}>
      <motion.div
        whileHover={{ y: -6 }}
        transition={{ type: "spring", stiffness: 300, damping: 22 }}
        className="group relative flex h-full flex-col overflow-hidden rounded-3xl border border-line bg-white p-7 shadow-[0_1px_0_rgba(13,27,42,0.04),0_20px_50px_-30px_rgba(13,27,42,0.35)]"
      >
        <span className="absolute inset-x-0 top-0 h-1.5" style={{ background: "var(--r)" }} aria-hidden="true" />
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-slate">{r.status}</p>
        <h3 className="font-display mt-3 text-3xl font-semibold text-marine">
          <a href={href(regionPath(r.slug))} className="after:absolute after:inset-0">{r.name}</a>
        </h3>
        <p className="mt-2 text-[0.95rem] leading-snug text-slate">{r.headline}</p>

        <ul className="mt-6 space-y-4">
          {r.schemes.map((s) => (
            <li key={s.name} className="flex gap-3">
              <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full" style={{ background: "var(--r)" }} aria-hidden="true" />
              <div>
                <p className="text-[0.95rem] font-semibold text-ink-2">
                  {s.name}
                  <span className="ml-2 rounded-full bg-pearl-2 px-2 py-0.5 align-middle text-[0.65rem] font-semibold uppercase tracking-wider text-marine-2">{KIND_LABEL[s.kind]}</span>
                </p>
                <p className="mt-0.5 text-sm leading-relaxed text-slate">{s.short}</p>
              </div>
            </li>
          ))}
        </ul>

        <p className="mt-auto pt-8 text-sm font-semibold text-marine transition group-hover:text-emerald">
          Détail et conditions <Icon name="arrow" className="ml-1 inline h-4 w-4 transition group-hover:translate-x-1" />
        </p>
      </motion.div>
    </Reveal>
  );
}

export function Regions() {
  return (
    <section id="regions" className="blueprint-grid-light relative bg-pearl py-24 sm:py-32">
      <div className="mx-auto max-w-7xl px-5 sm:px-8">
        <Reveal>
          <p className="text-xs font-medium uppercase tracking-[0.2em] text-emerald">Aides par région</p>
          <h2 className="font-display mt-4 max-w-3xl text-4xl font-semibold leading-tight text-marine sm:text-5xl">
            Ce qui reste en Wallonie, en Flandre et à Bruxelles
          </h2>
          <p className="mt-5 max-w-2xl text-lg text-slate">
            État des dispositifs de rénovation au {SITE.verifiedLabel}. Indicatif : seules les administrations régionales font foi.
          </p>
        </Reveal>

        <div className="mt-14 grid gap-6 lg:grid-cols-3">
          {REGION_ORDER.map((slug, i) => (
            <RegionCard key={slug} r={REGIONS[slug]} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
