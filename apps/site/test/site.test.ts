import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { beforeAll, describe, expect, it } from "vitest";

// Builds the static site twice (without and with contact settings) and checks the output.
function build(env: Record<string, string>): string {
  const out = mkdtempSync(join(tmpdir(), "dcard-site-"));
  execFileSync("pnpm", ["exec", "astro", "build", "--outDir", out], {
    cwd: join(import.meta.dirname, ".."),
    env: { ...process.env, SITE_URL: "https://site.example", SITE_APP_URL: "https://app.example", SITE_WHATSAPP: "", SITE_PHONE: "", SITE_EMAIL: "", ...env },
    stdio: "pipe",
  });
  return out;
}

const files = (dir: string): string[] =>
  readdirSync(dir, { withFileTypes: true }).flatMap((e) => (e.isDirectory() ? files(join(dir, e.name)) : [join(dir, e.name)]));

let plain: string;
let withContact: string;

beforeAll(() => {
  plain = build({});
  withContact = build({ SITE_WHATSAPP: "+255 754 000 111", SITE_PHONE: "0754000111", SITE_EMAIL: "hello@site.example" });
});

describe("marketing site", () => {
  it("ships no client JavaScript at all", () => {
    for (const f of files(plain)) {
      expect(f.endsWith(".js"), f).toBe(false);
      if (f.endsWith(".html")) expect(readFileSync(f, "utf8"), f).not.toMatch(/<script/i);
    }
  });

  it("renders every section in Swahili at / and English at /en/", () => {
    const sw = readFileSync(join(plain, "index.html"), "utf8");
    const en = readFileSync(join(plain, "en", "index.html"), "utf8");
    expect(sw).toContain('<html lang="sw"');
    expect(en).toContain('<html lang="en"');
    for (const id of ["how", "features", "pricing", "faq", "contact"]) {
      expect(sw).toContain(`id="${id}"`);
      expect(en).toContain(`id="${id}"`);
    }
    expect(sw).toContain("Inavyofanya kazi");
    expect(en).toContain("How it works");
  });

  it("shows the plan prices and pricing rules from the plans design", () => {
    for (const lang of ["index.html", join("en", "index.html")]) {
      const html = readFileSync(join(plain, lang), "utf8");
      for (const price of ["1,000", "1,500", "2,000", "50,000", "20%"]) expect(html, `${lang} ${price}`).toContain(price);
      for (const plan of ["Msingi", "Kawaida", "Premium"]) expect(html).toContain(plan);
    }
  });

  it("links sign-up to the app and hides contact buttons until configured", () => {
    const sw = readFileSync(join(plain, "index.html"), "utf8");
    expect(sw).toContain('href="https://app.example/signup"');
    expect(sw).not.toContain('data-contact="whatsapp"');
    expect(sw).not.toContain('data-contact="phone"');
    const configured = readFileSync(join(withContact, "index.html"), "utf8");
    expect(configured).toContain("https://wa.me/255754000111?text=");
    expect(configured).toContain('href="tel:+255754000111"');
    expect(configured).toContain("0754 000 111");
    expect(configured).toContain('data-contact="email"');
  });

  it("only uses brand and gold colours that exist in the theme", () => {
    const css = readFileSync(join(import.meta.dirname, "..", "src", "styles", "global.css"), "utf8");
    const defined = new Set([...css.matchAll(/--color-((?:brand|gold)-\d+)/g)].map((m) => m[1]));
    const used = new Set(
      files(join(import.meta.dirname, "..", "src"))
        .filter((f) => f.endsWith(".astro"))
        .flatMap((f) => [...readFileSync(f, "utf8").matchAll(/-((?:brand|gold)-\d+)/g)].map((m) => m[1])),
    );
    expect([...used].filter((c) => !defined.has(c))).toEqual([]);
  });

  it("sends calls to action to #contact while the web app URL is not set", () => {
    const noApp = build({ SITE_APP_URL: "" });
    const html = readFileSync(join(noApp, "index.html"), "utf8");
    expect(html).not.toContain("/signup");
    expect(html).toContain('href="#contact"');
  });

  it("has canonical, hreflang, Open Graph, sitemap and robots", () => {
    const sw = readFileSync(join(plain, "index.html"), "utf8");
    expect(sw).toContain('<link rel="canonical" href="https://site.example/"');
    expect(sw).toContain('hreflang="en" href="https://site.example/en/"');
    expect(sw).toContain('property="og:image" content="https://site.example/og.jpg"');
    expect(readFileSync(join(plain, "sitemap.xml"), "utf8")).toContain("<loc>https://site.example/en/</loc>");
    expect(readFileSync(join(plain, "robots.txt"), "utf8")).toContain("Sitemap: https://site.example/sitemap.xml");
  });
});
