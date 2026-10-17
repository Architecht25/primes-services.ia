import { MotionConfig } from "framer-motion";
import { Header } from "./components/Header";
import { Hero } from "./components/Hero";
import { Shift } from "./components/Shift";
import { Regions } from "./components/Regions";
import { RenovateSection } from "./components/RenovateSection";
import { About, ContactCta, Faq, Footer, ImageBand } from "./components/Sections";
import { RegionPage } from "./components/RegionPage";
import { GENERAL_FAQ, REGIONS, type RegionSlug } from "./content/site";
import { href } from "./lib/url";

export type PageId = "home" | RegionSlug | "notfound";

function NotFound() {
  return (
    <section className="blueprint-grid flex min-h-screen items-center bg-ink px-5 text-center text-white">
      <div className="mx-auto max-w-xl">
        <p className="font-display text-8xl font-semibold text-amber">404</p>
        <h1 className="font-display mt-4 text-3xl font-semibold">Cette page n'existe pas (ou plus).</h1>
        <p className="mt-3 text-white/70">Le site Primes Services a été simplifié : retrouvez les aides par région et l'accès à Ren0vate depuis l'accueil.</p>
        <a href={href("/")} className="mt-8 inline-block rounded-full bg-amber px-7 py-3 font-semibold text-ink">Retour à l'accueil</a>
      </div>
    </section>
  );
}

export function App({ page }: { page: PageId }) {
  return (
    <MotionConfig reducedMotion="user">
      <a href="#main" className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[60] focus:rounded focus:bg-amber focus:px-4 focus:py-2 focus:text-ink">
        Aller au contenu
      </a>
      <Header solid={page !== "home"} />
      <main id="main">
        {page === "home" && (
          <>
            <Hero />
            <Shift />
            <Regions />
            <RenovateSection />
            <ImageBand />
            <About />
            <Faq items={GENERAL_FAQ} />
            <ContactCta />
          </>
        )}
        {page === "notfound" && <NotFound />}
        {page !== "home" && page !== "notfound" && <RegionPage r={REGIONS[page]} />}
      </main>
      {page !== "notfound" && <Footer />}
    </MotionConfig>
  );
}
