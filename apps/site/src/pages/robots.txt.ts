import type { APIRoute } from "astro";

export const GET: APIRoute = ({ site }) =>
  new Response(`User-agent: *\nAllow: /\n\nSitemap: ${new URL("/sitemap.xml", site ?? "http://localhost:4321")}\n`, {
    headers: { "content-type": "text/plain; charset=utf-8" },
  });
