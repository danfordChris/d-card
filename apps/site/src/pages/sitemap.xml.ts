import type { APIRoute } from "astro";

export const GET: APIRoute = ({ site }) => {
  const base = site ?? new URL("http://localhost:4321");
  const sw = new URL("/", base).toString();
  const en = new URL("/en/", base).toString();
  const alt = `<xhtml:link rel="alternate" hreflang="sw" href="${sw}"/><xhtml:link rel="alternate" hreflang="en" href="${en}"/>`;
  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <url><loc>${sw}</loc>${alt}</url>
  <url><loc>${en}</loc>${alt}</url>
</urlset>
`;
  return new Response(body, { headers: { "content-type": "application/xml; charset=utf-8" } });
};
