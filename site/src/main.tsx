import { hydrateRoot, createRoot } from "react-dom/client";
import "./styles.css";
import { App, type PageId } from "./App";

const el = document.getElementById("root")!;
const PAGES = ["home", "wallonie", "flandre", "bruxelles", "notfound"];
const raw = el.dataset.page ?? "home";
const page = (PAGES.includes(raw) ? raw : "home") as PageId;

// Page prérendue → hydratation ; mode dev (vite) → rendu client.
if (el.firstElementChild) hydrateRoot(el, <App page={page} />);
else createRoot(el).render(<App page={page} />);
