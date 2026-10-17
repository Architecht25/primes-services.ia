import { useState } from "react";
import { AnimatePresence, motion, useScroll, useSpring } from "framer-motion";
import { LogoMark } from "./Logo";
import { Icon } from "./Icon";
import { href } from "../lib/url";
import { RENOVATE } from "../content/site";

const NAV = [
  { label: "Aides par région", to: "/#regions" },
  { label: "Ren0vate", to: "/#renovate" },
  { label: "Questions", to: "/#faq" },
  { label: "Contact", to: "/#contact" },
];

export function Header({ solid = false }: { solid?: boolean }) {
  const [open, setOpen] = useState(false);
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, { stiffness: 120, damping: 30, mass: 0.3 });

  return (
    <header className="fixed inset-x-0 top-0 z-50">
      <div className={`${solid ? "bg-ink/95" : "bg-ink/55"} backdrop-blur-xl border-b border-white/10`}>
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 sm:px-8">
          <a href={href("/")} className="flex items-center gap-3 text-white" aria-label="Primes Services – accueil">
            <LogoMark className="h-8 w-8 text-mint" />
            <span className="font-display text-lg font-semibold tracking-tight">Primes Services</span>
          </a>

          <nav aria-label="Navigation principale" className="hidden items-center gap-8 md:flex">
            {NAV.map((n) => (
              <a key={n.to} href={href(n.to)} className="text-sm text-white/75 transition hover:text-white">{n.label}</a>
            ))}
            <a
              href={RENOVATE.url}
              className="group inline-flex items-center gap-2 rounded-full bg-amber px-4 py-2 text-sm font-semibold text-ink transition hover:bg-amber-soft"
            >
              Ouvrir Ren0vate <Icon name="arrowUpRight" className="h-4 w-4 transition group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
            </a>
          </nav>

          <button
            type="button"
            className="inline-flex h-10 w-10 items-center justify-center rounded-full text-white md:hidden"
            aria-expanded={open}
            aria-controls="mobile-nav"
            aria-label={open ? "Fermer le menu" : "Ouvrir le menu"}
            onClick={() => setOpen((v) => !v)}
          >
            <Icon name={open ? "close" : "menu"} className="h-6 w-6" />
          </button>
        </div>
        <motion.div style={{ scaleX }} className="h-px origin-left bg-gradient-to-r from-mint via-amber to-mint" />
      </div>

      <AnimatePresence>
        {open && (
          <motion.nav
            id="mobile-nav"
            aria-label="Navigation mobile"
            initial={{ opacity: 0, y: -12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.25 }}
            className="border-b border-white/10 bg-ink/95 px-5 pb-6 pt-2 backdrop-blur-xl md:hidden"
          >
            {NAV.map((n) => (
              <a key={n.to} href={href(n.to)} onClick={() => setOpen(false)} className="block border-b border-white/10 py-4 text-lg text-white/90">{n.label}</a>
            ))}
            <a href={RENOVATE.url} className="mt-5 flex items-center justify-center gap-2 rounded-full bg-amber px-5 py-3 font-semibold text-ink">
              Ouvrir Ren0vate <Icon name="arrowUpRight" className="h-4 w-4" />
            </a>
          </motion.nav>
        )}
      </AnimatePresence>
    </header>
  );
}
