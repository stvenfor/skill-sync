import { type GrokTheme } from "../grok/hooks.js";
/**
 * The hues a Cursor page tints a category with: a `Swatch`, a `UsageBar`
 * segment. One name maps to the same hue in every component, so a
 * category's swatch and its share of a bar always match.
 */
export type CursorPageCategory = "gray" | "purple" | "green" | "yellow" | "cyan" | "pink" | "blue" | "orange" | "red";
/** Tints and inks for a unified diff, each read from the Grok palette's success and danger tones. */
export interface CursorPageDiffTones {
    /** Background of an added line. */
    readonly insertedLine: string;
    /** Background of a removed line. */
    readonly removedLine: string;
    /** The accent strip and line number of an added line, and the `+N` count. */
    readonly added: string;
    /** The accent strip and line number of a removed line, and the `-N` count. */
    readonly removed: string;
}
/**
 * The Grok theme with what Cursor's engineering-workflow blocks add on top
 * of it: diff tones and a category palette. Everything else, ink, surfaces,
 * type, radii, and data colors, is the Grok theme unchanged, so a Cursor
 * page looks like any other Grok page.
 */
export interface CursorPageTheme extends GrokTheme {
    readonly diff: CursorPageDiffTones;
    /** One hue per category name, for the viewer's polarity. */
    readonly category: Readonly<Record<CursorPageCategory, string>>;
}
/**
 * Returns the Cursor page theme for the viewer's current light/dark mode:
 * `useGrokTheme()` plus `diff` and `category`. Call it in each component
 * that needs colors; prefer the built-in components first.
 *
 * @example
 * ```tsx
 * function Delta() {
 *   const theme = useCursorPageTheme();
 *   return <span style={{ color: theme.diff.added }}>+12</span>;
 * }
 * ```
 */
export declare function useCursorPageTheme(): CursorPageTheme;
