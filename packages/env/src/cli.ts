import { checkEnv, formatReport } from "./check.js";
import { loadDotEnv } from "./load.js";

const path = loadDotEnv();
console.log(path ? `env: ${path}` : "env: no .env file found (using process environment)");
const report = checkEnv(process.env);
console.log(formatReport(report));
process.exit(report.ok ? 0 : 1);
