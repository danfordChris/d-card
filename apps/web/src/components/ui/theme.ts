/** Theme preference: stored in a cookie so the server renders the right theme (no flash). */
export const THEME_COOKIE = "dcard_theme";
export type ThemeChoice = "light" | "dark" | "system";

export function parseTheme(value: string | undefined | null): ThemeChoice {
  return value === "light" || value === "dark" ? value : "system";
}
