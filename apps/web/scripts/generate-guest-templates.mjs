// Generates the downloadable guest import templates in public/templates/.
// Run: pnpm --filter @dcard/web templates
import { writeFileSync } from "node:fs";
import writeExcelFile from "write-excel-file/node";

const header = ["name", "phone", "card_type", "partner_name"];
// Header only: example rows would be imported by mistake. The import page shows an example instead.
const dir = new URL("../public/templates/", import.meta.url);

await writeExcelFile([header], {
  columns: [{ width: 28 }, { width: 18 }, { width: 12 }, { width: 28 }],
}).toFile(new URL("guests-template.xlsx", dir).pathname);
writeFileSync(new URL("guests-template.csv", dir), header.join(",") + "\n");
console.log("templates written to public/templates/");
