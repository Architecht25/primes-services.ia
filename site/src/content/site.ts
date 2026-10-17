// Source unique des faits affichés sur le site, injectés dans le JSON-LD,
// llms.txt et llms-full.txt. Modifier ICI, jamais en dur dans les composants.

export type RegionSlug = "wallonie" | "flandre" | "bruxelles";

export const SITE = {
  name: "Primes Services",
  legalTagline: "Conseil en primes, subsides et prêts à taux 0 % pour la rénovation en Belgique",
  // Domaine canonique (surchargeable au build : SITE_URL=https://… npm run build)
  url: ((import.meta.env.VITE_SITE_URL as string | undefined) ?? "https://www.primes-services.be").replace(/\/$/, ""),
  locale: "fr-BE",
  email: "robin@primes-services.be",
  // Support technique et contact Ren0vate
  techEmail: "robin@architecht.be",
  phone: "+32 485 04 37 45",
  phoneHref: "+32485043745",
  foundingYear: 2010,
  // Date de dernière vérification manuelle des dispositifs (à mettre à jour à chaque revue).
  verifiedISO: "2026-10-17",
  verifiedLabel: "17 octobre 2026",
} as const;

export const RENOVATE = {
  name: "Ren0vate",
  url: "https://www.ren0vate.be/fr",
  signup: "https://www.ren0vate.be/fr/users/inscription",
  pricing: "https://www.ren0vate.be/fr/pricing",
  tagline: "Le passeport numérique de votre logement",
  description:
    "Ren0vate est l'application de gestion de chantier et de subsides de Primes Services : elle identifie les primes et prêts à taux 0 % applicables, compare les devis, suit les lots de travaux, centralise les documents et prépare le dossier technique du logement.",
} as const;

export const STATS = [
  { value: 15, prefix: "+", suffix: " ans", label: "d'expertise en primes et subsides belges" },
  { value: 15000, prefix: "+", suffix: "", label: "dossiers accompagnés" },
  { value: 100, prefix: "+", suffix: " M€", label: "de financements obtenus pour les ménages" },
] as const;

export const RENOVATE_FEATURES = [
  {
    icon: "target",
    title: "Primes & prêts identifiés",
    text: "Calcul des primes, du Rénopack, de Mijn VerbouwLening ou du Crédit EcoRéno selon votre région, vos revenus et vos travaux.",
  },
  {
    icon: "hammer",
    title: "Gestion de chantier par lot",
    text: "Toiture, isolation, menuiseries, électricité… planning, échéances, avancement et messagerie par lot de travaux.",
  },
  {
    icon: "scale",
    title: "Comparateur de devis",
    text: "Comparez les offres des entrepreneurs et mesurez l'impact de chacune sur votre financement.",
  },
  {
    icon: "folder",
    title: "Dossiers et documents",
    text: "Factures, permis, attestations : tout est centralisé, avec alertes en cas de pièce manquante avant dépôt.",
  },
  {
    icon: "camera",
    title: "Journal de chantier",
    text: "Observations datées, photos géolocalisées, procès-verbaux de réception et suivi des garanties.",
  },
  {
    icon: "vault",
    title: "Passeport numérique du logement",
    text: "Le dossier d'intervention ultérieure (DIU) se constitue au fil des travaux et reste exportable pour la vente ou la location.",
  },
] as const;

export const RENOVATE_STEPS = [
  { n: "01", title: "Créez votre projet", text: "Inscription gratuite : le premier projet se gère sans frais sur Ren0vate." },
  { n: "02", title: "Décrivez vos travaux", text: "Région, revenus, état du bien, lots de travaux envisagés." },
  { n: "03", title: "Obtenez votre plan de financement", text: "Primes encore ouvertes et prêts à taux 0 % applicables, calculés pour votre cas." },
  { n: "04", title: "Pilotez le chantier", text: "Devis, entrepreneurs, avancement, documents et dépôt des dossiers, au même endroit." },
] as const;

export type Scheme = {
  name: string;
  kind: "pret" | "prime" | "fiscal" | "fin";
  /** Résumé d'une phrase pour les cartes de la page d'accueil. */
  short: string;
  text: string;
};

export type Region = {
  slug: RegionSlug;
  name: string;
  fullName: string;
  nameNl?: string;
  accent: string; // classe CSS (var) — voir styles.css
  headline: string;
  status: string;
  summary: string;
  schemes: Scheme[];
  /** Conditions communes à connaître avant de se lancer. */
  conditions: string[];
  /** Ce qui est annoncé ou programmé. */
  upcoming: string[];
  /** Sources officielles consultées, avec leur date de mise à jour. */
  sourcesChecked: string;
  authority: { name: string; url: string; phone?: string };
  officialLinks: { label: string; url: string }[];
  cities: string[];
  faq: { q: string; a: string }[];
};

export const REGIONS: Record<RegionSlug, Region> = {
  wallonie: {
    slug: "wallonie",
    name: "Wallonie",
    fullName: "Région wallonne",
    accent: "wal",
    headline: "Rénopack, Rénoprêt, primes communales et Monuments et Sites",
    status: "Nouveau régime en vigueur depuis le 1er octobre 2026",
    summary:
      "Depuis le 1er octobre 2026, le soutien wallon à la rénovation énergétique prend la forme d'un système unique de prêt aidé : le Rénopack (taux 0 % avec réduction du montant à rembourser) et le Rénoprêt (taux 0 % ou préférentiel). L'aide est calculée sur l'ensemble des travaux éligibles. Les primes communales et les subventions Monuments et Sites restent disponibles.",
    schemes: [
      {
        name: "Rénopack",
        kind: "pret",
        short: "Prêt à 0 % avec 15 à 50 % du capital non remboursé selon les revenus (C1 à C3), jusqu'à 75 000 € pour une maison.",
        text: "Prêt à taux 0 % avec réduction du montant à rembourser, pour les ménages de catégorie C1 (revenus jusqu'à 28 900 € : 50 % de réduction), C2 (jusqu'à 41 100 € : 40 %) et C3 (jusqu'à 67 100 € : 15 %). Jusqu'à 75 000 € pour une maison unifamiliale, 60 000 € par logement pour un appartement. Réduction de 5 000 € par personne à charge sur le revenu imposable ; majoration de 5 % pour l'utilisation d'écomatériaux. Il faut être titulaire d'un droit réel, s'engager à occuper le logement dans les 24 mois et ne pas être multipropriétaire.",
      },
      {
        name: "Rénoprêt",
        kind: "pret",
        short: "Prêt à 0 % ou à taux préférentiel pour la catégorie C4, les propriétaires-bailleurs et les copropriétés.",
        text: "Prêt à taux 0 % ou préférentiel (plus avantageux que le marché), selon la nature des travaux, le profil du demandeur et sa catégorie de revenus. Destiné aux ménages de catégorie C4 (de 67 100 € à 122 800 €), aux propriétaires-bailleurs et aux associations de copropriétaires. Taux 0 % pour l'adaptation au handicap et la réhabilitation après une calamité naturelle reconnue. Copropriétés (parties communes) : taux 0 % jusqu'à 60 000 € par logement, avec un plafond global de 600 000 € (moins de 20 lots) ou 750 000 € (20 lots ou plus).",
      },
      {
        name: "Primes communales",
        kind: "prime",
        short: "Certaines communes wallonnes proposent leurs propres primes à la rénovation.",
        text: "Certaines communes wallonnes proposent leurs propres primes à la rénovation. Les montants et les conditions varient d'une commune à l'autre : renseignez-vous auprès de votre administration communale.",
      },
      {
        name: "Monuments et Sites",
        kind: "prime",
        short: "Subvention de l'AWaP pour les biens classés : études préalables à 80 %, travaux d'entretien et de restauration à 50 %.",
        text: "Subvention de la Région wallonne (Agence wallonne du Patrimoine) pour les biens classés : études préalables à 80 % ; travaux d'urgence, d'entretien et de restauration à 50 %, majorés de 15 % pour le patrimoine exceptionnel et de 10 % dans certains cas (fonction culturelle ou scolaire, logement d'utilité publique, parties classées accessibles au public). Interventions minimales de 4 % de la province et de 1 % de la commune. Le cumul de subventions ne peut dépasser 100 % du coût des travaux.",
      },
    ],
    conditions: [
      "Logement en label PEB G ou F : les travaux doivent permettre d'atteindre au minimum le label D (ESPEC ≤ 340 kWh/m².an) ; en label E : au minimum le label C (ESPEC ≤ 255 kWh/m².an). Des dérogations sont possibles si l'objectif est impossible pour des raisons techniques, fonctionnelles ou économiques justifiées.",
      "Un audit préalable aux travaux est obligatoire (rapport de moins d'un an). Son coût peut être intégré au financement ; pour la catégorie C1, l'expertise réalisée pour le Rénopack peut en tenir lieu.",
      "L'aide régionale est calculée globalement sur l'ensemble des travaux éligibles, et non plus poste par poste.",
      "Accompagnement à trois niveaux (information, accompagnement personnalisé, prise en charge approfondie) via les Guichets Énergie Wallonie, les Espaces Wallonie, les plates-formes locales de rénovation, la SWCS et le FLW.",
    ],
    upcoming: [
      "1er janvier 2028 : l'Agence wallonne de l'Habitation pilotera le dispositif, avec un système d'agrément des opérateurs.",
    ],
    sourcesChecked:
      "Portail wallonie.be, régime de soutien à la rénovation énergétique (publié le 17 juillet 2026, mis à jour le 25 septembre 2026) ; wallonie.be et Agence wallonne du Patrimoine, subventions biens classés (mise à jour du 21 septembre 2026).",
    authority: { name: "Guichets Énergie Wallonie (SPW)", url: "https://energie.wallonie.be", phone: "1718" },
    officialLinks: [
      { label: "wallonie.be – nouveau régime de soutien à la rénovation", url: "https://www.wallonie.be/fr/actualites/renovation-energetique-les-grandes-lignes-du-futur-regime-de-soutien-sont-connues" },
      { label: "Énergie Wallonie – aides et soutiens financiers", url: "https://energie.wallonie.be" },
      { label: "Agence wallonne du Patrimoine – subsides", url: "https://agencewallonnedupatrimoine.be/subsides/" },
    ],
    cities: ["Liège", "Charleroi", "Namur", "Mons", "Tournai", "Verviers", "La Louvière", "Seraing"],
    faq: [
      {
        q: "Quelles aides à la rénovation existent en Wallonie ?",
        a: "Le Rénopack (prêt à 0 % avec réduction du montant à rembourser, catégories de revenus C1 à C3), le Rénoprêt (prêt à 0 % ou préférentiel, catégorie C4, propriétaires-bailleurs et copropriétés), les primes communales et les subventions Monuments et Sites pour les biens classés.",
      },
      {
        q: "Qu'est-ce que le Rénopack ?",
        a: "C'est un prêt à taux 0 % avec réduction du montant à rembourser : 50 % pour la catégorie C1 (revenus jusqu'à 28 900 €), 40 % pour C2 (jusqu'à 41 100 €) et 15 % pour C3 (jusqu'à 67 100 €). Il finance jusqu'à 75 000 € pour une maison unifamiliale et 60 000 € par logement pour un appartement.",
      },
      {
        q: "Qui peut obtenir le Rénoprêt ?",
        a: "Les ménages de catégorie C4 (revenus de 67 100 € à 122 800 €), les propriétaires-bailleurs et les associations de copropriétaires. Le taux est 0 % ou préférentiel selon les travaux et le profil ; il est de 0 % pour l'adaptation au handicap, la réhabilitation après calamité naturelle et les parties communes de copropriété (jusqu'à 60 000 € par logement).",
      },
      {
        q: "Quelles conditions pour obtenir un Rénopack ou un Rénoprêt ?",
        a: "Le logement doit être en label PEB G ou F (objectif : au moins D) ou E (objectif : au moins C), et un audit préalable aux travaux est obligatoire ; son coût peut être financé. L'aide est calculée sur l'ensemble des travaux éligibles.",
      },
    ],
  },
  flandre: {
    slug: "flandre",
    name: "Flandre",
    fullName: "Vlaams Gewest",
    nameNl: "Vlaanderen",
    accent: "vla",
    headline: "Mijn VerbouwLening, Mijn VerbouwPremie et primes communales",
    status: "Régime 2026 en vigueur ; taux de base ajusté en 2027",
    summary:
      "En Flandre, Mijn VerbouwLening finance de 4 000 € à 60 000 € sur 25 ans maximum, à 1,5 %, 0,5 % ou 0 % en 2026 selon la catégorie de revenus. Mijn VerbouwPremie, la prime de la Région, reste disponible : depuis le 1er mars 2026, les catégories de revenus 1 et 2 ne peuvent l'obtenir que pour une pompe à chaleur ou un chauffe-eau thermodynamique. Les communes complètent par leurs propres primes.",
    schemes: [
      {
        name: "Mijn VerbouwLening",
        kind: "pret",
        short: "De 4 000 € à 60 000 € sur 25 ans maximum ; taux 2026 : 1,5 % (catégorie 2), 0,5 % (catégorie 3), 0 % (catégorie 4).",
        text: "Prêt de 4 000 € à 60 000 €, remboursable sur 25 ans maximum, jusqu'à concurrence de la facture TVA comprise, demandé sur devis avant les travaux via le Mijn VerbouwLoket. Taux 2026 : 1,5 % pour la catégorie 2, 0,5 % pour la catégorie 3 et 0 % pour la catégorie 4 (taux de base 1,5 % avec réduction de 1 % et 2 % pour les catégories 3 et 4) ; la catégorie 1 n'y a pas droit. Ouvert aux propriétaires-occupants des catégories 2 à 4, aux bailleurs privés (conditions supplémentaires), aux bailleurs via une société de logement social et aux associations de copropriétaires. Il couvre toutes les catégories de travaux de Mijn VerbouwPremie (toiture, murs extérieurs, sol, châssis et portes, travaux préparatoires, pompe à chaleur, chauffe-eau thermodynamique) ainsi que les panneaux solaires. Le bâtiment doit en principe avoir été raccordé au réseau avant le 1er janvier 2006 (sauf pompe à chaleur et solaire).",
      },
      {
        name: "Mijn VerbouwPremie",
        kind: "prime",
        short: "Prime de la Région flamande pour les travaux énergétiques ; catégories 1 et 2 : pompe à chaleur et chauffe-eau thermodynamique uniquement.",
        text: "Prime de la Région flamande pour les travaux de rénovation énergétique (toiture, murs, sol, châssis, pompe à chaleur, chauffe-eau thermodynamique…). Depuis le 1er mars 2026, les propriétaires-occupants des catégories de revenus 1 et 2 ne peuvent l'obtenir que pour une pompe à chaleur ou un chauffe-eau thermodynamique ; les catégories 3 et 4 restent éligibles à l'ensemble des travaux de la prime. Le montant se calcule avec le simulateur officiel (apps.energiesparen.be).",
      },
      {
        name: "Primes communales",
        kind: "prime",
        short: "Certaines communes flamandes proposent leurs propres primes ; l'Energiehuis communal oriente les demandes.",
        text: "Certaines communes flamandes proposent leurs propres primes à la rénovation. Les montants et conditions varient d'une commune à l'autre : renseignez-vous auprès de votre commune ou de l'Energiehuis (ligne gratuite 1700).",
      },
    ],
    conditions: [
      "Seuils de revenus 2026 (dernier avertissement-extrait de rôle connu), personne isolée : catégorie 4 jusqu'à 24 750 € ; catégorie 3 jusqu'à 43 240 € ; catégorie 2 jusqu'à 55 020 €. Isolé avec une personne à charge ou couple sans personne à charge : 37 110 €, 60 520 € et 78 610 €. Majoration de 4 420 € par personne à charge supplémentaire.",
      "Mijn VerbouwLening : si vous n'habitez pas encore le logement, vous avez 36 mois après l'octroi pour y établir votre domicile.",
      "Si vous recevez ensuite une Mijn VerbouwPremie, son montant est automatiquement déduit du capital restant dû du prêt.",
    ],
    upcoming: [
      "2027 : le taux de base de Mijn VerbouwLening sera ajusté en fonction du taux légal fixé au niveau fédéral.",
      "2027 (projet, règles non définitives) : une prime de 35 % pour les bailleurs privés sur les travaux admissibles de la catégorie 3, sous conditions (loyer plafonné, certificat de conformité, location d'au moins trois ans).",
    ],
    sourcesChecked:
      "Brochure officielle Mijn VerbouwLening de la Vlaamse overheid / VEKA (édition de juin 2026) ; pages vlaanderen.be Mijn VerbouwLening et Mijn VerbouwPremie (consultées le 17 octobre 2026).",
    authority: { name: "Vlaams Energie- en Klimaatagentschap (VEKA) – Energiehuis", url: "https://www.mijnenergiehuis.be", phone: "1700" },
    officialLinks: [
      { label: "Mijn VerbouwPremie – vlaanderen.be", url: "https://www.vlaanderen.be/mijn-verbouwpremie" },
      { label: "Mijn VerbouwLening – mijnverbouwlening.be", url: "https://www.mijnverbouwlening.be" },
      { label: "Simulateur Mijn VerbouwLening", url: "https://apps.energiesparen.be/simulator-mijnverbouwlening" },
    ],
    cities: ["Anvers", "Gand", "Bruges", "Louvain", "Malines", "Alost", "Courtrai", "Ostende"],
    faq: [
      {
        q: "Quelles aides à la rénovation existent en Flandre ?",
        a: "Mijn VerbouwLening (prêt de 4 000 € à 60 000 € à taux réduit jusqu'à 0 %), Mijn VerbouwPremie (prime régionale pour les travaux énergétiques) et les primes communales selon la commune.",
      },
      {
        q: "Quel est le taux de Mijn VerbouwLening en 2026 ?",
        a: "Le taux de base 2026 est de 1,5 % sur toute la durée du prêt, avec une réduction supplémentaire de 1 % pour la catégorie de revenus 3 et de 2 % pour la catégorie 4 : soit 1,5 % (catégorie 2), 0,5 % (catégorie 3) et 0 % (catégorie 4). Le montant va de 4 000 € à 60 000 €, sur 25 ans maximum.",
      },
      {
        q: "Qui peut recevoir Mijn VerbouwPremie ?",
        a: "Les propriétaires-occupants, selon leur catégorie de revenus. Depuis le 1er mars 2026, les catégories 1 et 2 ne peuvent l'obtenir que pour une pompe à chaleur ou un chauffe-eau thermodynamique ; les catégories 3 et 4 restent éligibles à l'ensemble des travaux de la prime. Les investisseurs et bailleurs privés ne sont éligibles que pour les travaux énergétiques (isolation, vitrage à haut rendement, pompe à chaleur).",
      },
    ],
  },
  bruxelles: {
    slug: "bruxelles",
    name: "Bruxelles-Capitale",
    fullName: "Région de Bruxelles-Capitale",
    accent: "bru",
    headline: "Monuments et Sites, Petit Patrimoine, primes communales et Crédit EcoRéno",
    status: "Prêts à 0 % annoncés pour le printemps 2027",
    summary:
      "À Bruxelles, la Région soutient la rénovation par des subventions patrimoine (biens classés et petit patrimoine), les primes communales et le Crédit EcoRéno du Fonds du Logement (2,5 % ou 3,5 % selon les revenus). Le gouvernement bruxellois a annoncé dans son accord budgétaire d'octobre 2026 des prêts énergie et rénovation à taux 0 % pour les ménages, attendus au printemps 2027.",
    schemes: [
      {
        name: "Monuments et Sites",
        kind: "prime",
        short: "Subventions pour la conservation des biens classés : études préalables à 80 %, travaux à 40 ou 50 % pour les privés.",
        text: "Subventions de la Région pour les travaux de conservation d'un bien classé : études préalables subventionnées à 80 % ; autres travaux à 80 % pour les bénéficiaires publics et à 40 % ou 50 % pour les privés selon les travaux, avec des majorations possibles selon les revenus, la situation du bien ou le type de travaux. La demande s'introduit auprès d'urban.brussels (restauration@urban.brussels), avant le début des travaux.",
      },
      {
        name: "Petit Patrimoine",
        kind: "prime",
        short: "Prime pour restaurer le petit patrimoine non protégé : 50 % du coût hors TVA (plafond 10 000 €), jusqu'à 75 % selon les revenus.",
        text: "Prime pour la restauration du petit patrimoine non protégé : 50 % du coût des travaux hors TVA pour les privés, plafonnée à 10 000 € par immeuble sur 5 ans. Majoration portant l'aide à 75 % (plafond de 15 000 €) si les revenus sont inférieurs à 40 000 € par an (+ 2 500 € par personne à charge) ou si l'immeuble se trouve dans un périmètre de revitalisation des quartiers. Pas d'aide pour l'entretien ni pour les travaux déjà réalisés.",
      },
      {
        name: "Primes communales",
        kind: "prime",
        short: "Certaines communes bruxelloises proposent leurs propres primes à la rénovation.",
        text: "Certaines des 19 communes bruxelloises proposent leurs propres primes à la rénovation. Les montants et les conditions varient d'une commune à l'autre : contactez directement votre commune.",
      },
      {
        name: "Crédit EcoRéno",
        kind: "pret",
        short: "Crédit du Fonds du Logement à 2,5 % ou 3,5 % selon les revenus, pour propriétaires et locataires.",
        text: "Crédit à taux préférentiel du Fonds du Logement, relancé le 1er janvier 2026 : 2,5 % ou 3,5 % selon les revenus de l'emprunteur (donc hors taux 0 %). Pour les propriétaires, futurs propriétaires et locataires d'un bien situé dans l'une des 19 communes, sous plafonds de revenus, pour l'isolation, la ventilation, le chauffage, le photovoltaïque, les pompes à chaleur et les chauffe-eau solaires. Les demandes de crédit hypothécaire ne sont traitées que dans certains cas (clients existants du Fonds du Logement, logements construits par le Fonds).",
      },
    ],
    conditions: [
      "Monuments et Sites : le dossier se dépose avec le formulaire officiel auprès de la Direction du Patrimoine culturel (urban.brussels) ; l'entretien courant et les parties non classées ne sont pas subventionnés.",
      "Petit Patrimoine : ouvert aux propriétaires, copropriétaires et titulaires d'un droit réel ou d'un bail commercial, dans la limite des budgets disponibles.",
      "Crédit EcoRéno : montants, durées et plafonds de revenus sont précisés par le Fonds du Logement (fonds.brussels).",
    ],
    upcoming: [
      "Printemps 2027 : prêts énergie et rénovation à taux 0 % pour les ménages bruxellois, annoncés dans l'accord budgétaire du gouvernement bruxellois (octobre 2026). Les modalités doivent encore être présentées au gouvernement.",
    ],
    sourcesChecked:
      "be.brussels (aides à la rénovation) ; renolution.brussels et fonds.brussels (crédit ECORENO, mise à jour du 27 février 2026) ; patrimoine.brussels (subventions biens classés et petit patrimoine). Annonce des prêts à 0 % : presse (RTBF, La Libre, 4 au 6 octobre 2026), aucun texte officiel publié à ce jour.",
    authority: { name: "Bruxelles Environnement / urban.brussels / Fonds du Logement", url: "https://be.brussels/fr/logement/construction-et-renovation", phone: "02 775 75 75" },
    officialLinks: [
      { label: "be.brussels – aides à la rénovation", url: "https://be.brussels/en/housing/construction-and-renovation/renovation-subsidies-and-financial-support" },
      { label: "Fonds du Logement – Crédit EcoRéno", url: "https://fonds.brussels/fr/credits/credit-renovation" },
      { label: "patrimoine.brussels – aides financières", url: "https://patrimoine.brussels/agir/aide-financiere" },
      { label: "Presse (RTBF) – accord sur des prêts énergie et rénovation à 0 %", url: "https://www.rtbf.be/article/accord-sur-des-prets-energie-et-renovation-a-0-pour-les-menages-bruxellois-dans-le-budget-2027-de-la-region-bruxelloise-11794913" },
      { label: "Presse (La Libre) – ce que le budget bruxellois va changer", url: "https://www.lalibre.be/belgique/societe/2026/10/06/taxe-economies-pret-a-0-fiscalite-auto-ce-que-le-budget-bruxellois-va-changer-a-votre-quotidien-JEROXATQPFF2VPBVKT62PNXIPQ/" },
    ],
    cities: ["Bruxelles-Ville", "Ixelles", "Uccle", "Schaerbeek", "Anderlecht", "Woluwe-Saint-Lambert", "Etterbeek", "Molenbeek"],
    faq: [
      {
        q: "Quelles aides à la rénovation existent à Bruxelles ?",
        a: "Les subventions Monuments et Sites pour les biens classés, la prime Petit Patrimoine, les primes communales (selon la commune) et le Crédit EcoRéno du Fonds du Logement (2,5 % ou 3,5 % selon les revenus).",
      },
      {
        q: "Des prêts à 0 % arrivent-ils à Bruxelles ?",
        a: "Oui : le gouvernement bruxellois a annoncé dans son accord budgétaire d'octobre 2026 des prêts énergie et rénovation à taux 0 % pour les ménages, attendus au printemps 2027. Les modalités ne sont pas encore publiées : ils ne doivent pas être intégrés à un plan de financement avant leur entrée en vigueur.",
      },
      {
        q: "Qu'est-ce que le Crédit EcoRéno ?",
        a: "Un crédit du Fonds du Logement relancé le 1er janvier 2026, à 2,5 % ou 3,5 % selon les revenus, pour les propriétaires, futurs propriétaires et locataires d'un bien dans l'une des 19 communes bruxelloises (isolation, ventilation, chauffage, photovoltaïque, pompes à chaleur, chauffe-eau solaires).",
      },
      {
        q: "Comment fonctionne la prime Petit Patrimoine ?",
        a: "Elle couvre 50 % du coût hors TVA de la restauration du petit patrimoine non protégé, plafonnée à 10 000 € par immeuble sur 5 ans, avec une majoration jusqu'à 75 % (plafond 15 000 €) si les revenus sont inférieurs à 40 000 € par an ou si l'immeuble est en périmètre de revitalisation.",
      },
    ],
  },
};

export const REGION_ORDER: RegionSlug[] = ["wallonie", "flandre", "bruxelles"];

export const GENERAL_FAQ = [
  {
    q: "Qu'est-ce que Primes Services ?",
    a: "Primes Services est une société belge de conseil en primes, subsides et prêts à taux 0 % pour la rénovation, active depuis plus de 15 ans en Wallonie, en Flandre et à Bruxelles. Elle a accompagné plus de 15 000 dossiers et contribué à obtenir plus de 100 millions d'euros de financements.",
  },
  {
    q: "Quel est le lien entre Primes Services et Ren0vate ?",
    a: "Ren0vate est l'application de gestion de chantier et de subsides de Primes Services. Toutes les nouvelles demandes passent exclusivement par Ren0vate : l'application identifie les primes et prêts à taux 0 % applicables, suit le chantier et prépare les dossiers.",
  },
  {
    q: "Ren0vate est-il gratuit ?",
    a: "Le premier projet se gère gratuitement sur Ren0vate. Les fonctionnalités multi-biens et professionnelles sont proposées sur abonnement (voir la page tarifs de Ren0vate).",
  },
  {
    q: "Quelles aides à la rénovation restent disponibles en Belgique en 2026 ?",
    a: "En Wallonie : le Rénopack, le Rénoprêt, les primes communales et Monuments et Sites. En Flandre : Mijn VerbouwLening, Mijn VerbouwPremie et les primes communales. À Bruxelles : Monuments et Sites, Petit Patrimoine, les primes communales et le Crédit EcoRéno, avec des prêts à taux 0 % annoncés pour le printemps 2027.",
  },
  {
    q: "Comment contacter Primes Services ?",
    a: `Pour un dossier de rénovation, créez votre projet sur Ren0vate. Pour toute autre question (partenariat, presse, demande particulière), écrivez à ${SITE.email} ou appelez le ${SITE.phone}. Pour une question technique ou sur l'application Ren0vate : ${SITE.techEmail}.`,
  },
  {
    q: "Les informations de ce site sont-elles officielles ?",
    a: "Non. Primes Services n'est pas un organisme public. Les informations sont indicatives, vérifiées le " +
      SITE.verifiedLabel +
      " à partir de sources publiques ; seules les administrations régionales font foi. Les liens officiels sont indiqués pour chaque région.",
  },
];

export const KIND_LABEL: Record<Scheme["kind"], string> = {
  pret: "Prêt",
  prime: "Prime",
  fiscal: "Fiscalité",
  fin: "Annoncé",
};
