import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";
import { Reveal } from "../lib/motion";
import { Icon } from "./Icon";
import { LogoMark } from "./Logo";
import { CLOSURE, SITE } from "../content/site";
import { href } from "../lib/url";

export function ImageBand() {
  const ref = useRef<HTMLElement>(null);
  const reduce = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], ["-7%", "7%"]);
  return (
    <section ref={ref} className="relative isolate flex min-h-[70vh] items-center overflow-hidden bg-ink">
      <motion.img
        src={href("/img/bruxelles-1600.webp")}
        srcSet={`${href("/img/bruxelles-800.webp")} 800w, ${href("/img/bruxelles-1600.webp")} 1600w`}
        sizes="100vw"
        alt="Rue bruxelloise bordée de maisons de ville en brique et façades Art nouveau"
        width={1600} height={1071} loading="lazy"
        style={reduce ? undefined : { y }}
        className="absolute inset-x-0 top-[-12%] -z-10 h-[124%] w-full object-cover"
      />
      <div className="absolute inset-0 -z-10 bg-gradient-to-r from-ink/90 via-ink/60 to-ink/20" aria-hidden="true" />
      <div className="mx-auto w-full max-w-7xl px-5 py-24 sm:px-8">
        <Reveal>
          <p className="font-display max-w-3xl text-4xl font-semibold leading-tight text-white sm:text-6xl">
            Rénover, c'est d'abord <span className="text-amber">bien financer</span>.
          </p>
          <p className="mt-6 max-w-xl text-lg text-white/75">
            Un bâti ancien, des règles qui changent d'une région à l'autre : renseignez-vous sur ce qui est encore ouvert
            avant le premier coup de marteau.
          </p>
        </Reveal>
      </div>
    </section>
  );
}

export function About() {
  return (
    <section id="a-propos" className="bg-white py-24 sm:py-32">
      <div className="mx-auto grid max-w-7xl gap-14 px-5 sm:px-8 lg:grid-cols-2">
        <Reveal>
          <p className="text-xs font-medium uppercase tracking-[0.2em] text-emerald">À propos</p>
          <h2 className="font-display mt-4 text-4xl font-semibold leading-tight text-marine sm:text-5xl">
            Primes Services : 15 ans au service des propriétaires
          </h2>
          <p className="mt-6 text-lg leading-relaxed text-slate">
            Depuis {SITE.foundingYear}, Primes Services conseille particuliers, copropriétés et entreprises pour obtenir les primes,
            subsides et prêts à taux avantageux de la rénovation en Belgique : plus de 15 000 dossiers accompagnés et plus de
            100 millions d'euros de financements obtenus.
          </p>
          <p className="mt-4 text-lg leading-relaxed text-slate">
            Primes Services arrête ses activités à partir de <strong className="text-marine">{CLOSURE.activityEnd}</strong>. Ce site reste en ligne
            pour vous orienter vers les aides régionales encore ouvertes et vers les administrations compétentes.
          </p>
        </Reveal>

        <Reveal delay={2} className="grid items-start gap-4 sm:grid-cols-2">
          <div className="rounded-3xl bg-marine p-7 text-white">
            <p className="text-xs font-semibold uppercase tracking-widest text-mint">Arrêt des activités</p>
            <ul className="mt-4 space-y-2.5">
              {[`Depuis le ${CLOSURE.contactEndLabel} : plus de contact possible`, `À partir de ${CLOSURE.activityEnd} : activités arrêtées`, "Aides par région : consultables sur ce site"].map((t) => (
                <li key={t} className="flex gap-2"><Icon name="check" className="mt-1 h-4 w-4 shrink-0 text-mint" />{t}</li>
              ))}
            </ul>
          </div>
          <div className="rounded-3xl border border-line bg-pearl p-7">
            <p className="text-xs font-semibold uppercase tracking-widest text-slate">À venir dans les aides</p>
            <ul className="mt-4 space-y-2.5 text-slate">
              {["Printemps 2027 : prêts à 0 % annoncés à Bruxelles", "2027 : taux de Mijn VerbouwLening ajusté", "1er janvier 2028 : Agence wallonne de l'Habitation"].map((t) => (
                <li key={t} className="flex gap-2"><span className="text-pearl-600">→</span>{t}</li>
              ))}
            </ul>
          </div>
        </Reveal>
      </div>
    </section>
  );
}

export function Faq({ items, title = "Questions fréquentes", id = "faq", tone = "pearl" }: {
  items: { q: string; a: string }[]; title?: string; id?: string; tone?: "pearl" | "white";
}) {
  return (
    <section id={id} className={`${tone === "white" ? "bg-white" : "bg-pearl"} py-24 sm:py-28`}>
      <div className="mx-auto max-w-4xl px-5 sm:px-8">
        <Reveal>
          <h2 className="font-display text-4xl font-semibold text-marine sm:text-5xl">{title}</h2>
        </Reveal>
        <div className="mt-10 divide-y divide-line border-y border-line">
          {items.map((f) => (
            <details key={f.q} className="group py-1">
              <summary className="flex cursor-pointer items-center justify-between gap-6 py-5 text-left">
                <h3 className="text-lg font-semibold text-marine">{f.q}</h3>
                <span className="faq-chevron flex h-9 w-9 shrink-0 items-center justify-center rounded-full border border-line text-marine group-hover:border-marine">
                  <Icon name="plus" className="h-4 w-4" />
                </span>
              </summary>
              <p className="max-w-3xl pb-6 pr-12 leading-relaxed text-slate">{f.a}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}

export function ClosureNotice() {
  return (
    <section id="arret" aria-labelledby="arret-titre" className="blueprint-grid grain relative isolate overflow-hidden bg-ink py-24 text-white sm:py-32">
      <div className="pointer-events-none absolute left-1/2 top-0 -z-10 h-[30rem] w-[50rem] -translate-x-1/2 rounded-full bg-amber/15 blur-[140px]" aria-hidden="true" />
      <div className="mx-auto max-w-4xl px-5 text-center sm:px-8">
        <Reveal>
          <LogoMark className="mx-auto mb-8 h-14 w-14 text-mint" />
          <p className="mx-auto inline-flex rounded-full border border-amber/40 bg-amber/10 px-4 py-1.5 text-xs font-medium uppercase tracking-[0.18em] text-amber">Information importante</p>
          <h2 id="arret-titre" className="font-display mt-6 text-4xl font-semibold leading-tight sm:text-6xl">
            Primes Services arrête ses activités à partir de <span className="text-amber">{CLOSURE.activityEnd}</span>.
          </h2>
          <p className="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-white/70">
            Nous remercions les particuliers, copropriétés et entreprises qui nous ont fait confiance depuis {SITE.foundingYear}.
          </p>
        </Reveal>

        <Reveal delay={2} className="mx-auto mt-12 max-w-2xl rounded-3xl border border-white/15 bg-white/[0.04] p-8 text-left backdrop-blur sm:p-10">
          <h3 className="font-display text-2xl font-semibold">Il n'est plus possible de nous contacter depuis le {CLOSURE.contactEndLabel}.</h3>
          <p className="mt-3 leading-relaxed text-white/70">
            Le formulaire et les coordonnées de contact ne sont plus proposés sur ce site. Pour toute question sur une prime ou un prêt,
            adressez-vous directement à l'administration de votre région : les liens officiels sont indiqués sur chaque page régionale.
          </p>
          <div className="mt-7 flex flex-col gap-3 sm:flex-row">
            <a href={href("/#regions")} className="btn-shine group relative inline-flex items-center justify-center gap-2 overflow-hidden rounded-full bg-amber px-7 py-3.5 font-semibold text-ink transition hover:bg-amber-soft">
              Voir les aides par région <Icon name="arrow" className="h-5 w-5 transition group-hover:translate-x-1" />
            </a>
          </div>
        </Reveal>
      </div>
    </section>
  );
}

export function Footer() {
  return (
    <footer className="bg-ink-2 text-white/70">
      <div className="mx-auto max-w-7xl px-5 py-14 sm:px-8">
        <div className="grid gap-10 md:grid-cols-[1.4fr_1fr_1fr]">
          <div>
            <a href={href("/")} className="flex items-center gap-3 text-white">
              <LogoMark className="h-9 w-9 text-mint" /><span className="font-display text-xl font-semibold">Primes Services</span>
            </a>
            <p className="mt-4 max-w-sm text-sm leading-relaxed">{SITE.legalTagline}. Wallonie, Flandre, Bruxelles.</p>
          </div>
          <nav aria-label="Pied de page – régions">
            <p className="text-sm font-semibold text-white">Aides par région</p>
            <ul className="mt-3 space-y-2 text-sm">
              <li><a className="hover:text-white" href={href("/regions/wallonie/")}>Wallonie</a></li>
              <li><a className="hover:text-white" href={href("/regions/flandre/")}>Flandre</a></li>
              <li><a className="hover:text-white" href={href("/regions/bruxelles/")}>Bruxelles-Capitale</a></li>
            </ul>
          </nav>
          <div>
            <p className="text-sm font-semibold text-white">Arrêt des activités</p>
            <p className="mt-3 text-sm leading-relaxed">
              Primes Services arrête ses activités à partir de {CLOSURE.activityEnd}. Plus de contact possible depuis le {CLOSURE.contactEndLabel}.
            </p>
            <p className="mt-3 text-sm"><a className="underline underline-offset-4 hover:text-white" href={href("/#arret")}>En savoir plus</a></p>
          </div>
        </div>
        <div className="mt-12 border-t border-white/10 pt-6 text-xs leading-relaxed text-white/50">
          <p>
            Primes Services n'est pas un organisme public. Les informations de ce site sont indicatives, vérifiées le {SITE.verifiedLabel} à partir de sources publiques,
            et ne constituent pas un conseil juridique ou financier. Seules les administrations régionales font foi.
          </p>
          <p className="mt-3">© {new Date(SITE.verifiedISO).getFullYear()} Primes Services.</p>
        </div>
      </div>
    </footer>
  );
}
