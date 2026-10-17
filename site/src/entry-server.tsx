import { renderToString } from "react-dom/server";
import { App, type PageId } from "./App";
import { headFor } from "./seo/head";
import { LEGACY_REDIRECTS, PAGES } from "./seo/pages";
import { llmsFullTxt, llmsTxt, robotsTxt, sitemapXml } from "./seo/llms";
import { abs, href } from "./lib/url";
import { SITE } from "./content/site";

export const render = (page: PageId) => renderToString(<App page={page} />);
export { headFor, PAGES, LEGACY_REDIRECTS, llmsFullTxt, llmsTxt, robotsTxt, sitemapXml, abs, href, SITE };
