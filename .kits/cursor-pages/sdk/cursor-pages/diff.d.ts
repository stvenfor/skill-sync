import type { CSSProperties, JSX } from "react";
export interface DiffStatsProps {
    additions?: number;
    deletions?: number;
    style?: CSSProperties;
}
/**
 * Inline `+N` / `-N` pair in the success and danger inks, with tabular
 * numerals so columns of them line up. Renders nothing when both counts
 * are zero. Put it beside a file name, in a table cell, or in a
 * `CollapsibleSection`'s `trailing` slot.
 *
 * @example
 * ```tsx
 * <CollapsibleSection title="src/utils.ts" trailing={<DiffStats additions={12} deletions={3} />}>
 *   <DiffView path="src/utils.ts" lines={lines} />
 * </CollapsibleSection>
 * ```
 */
export declare function DiffStats({ additions, deletions, style, }: DiffStatsProps): JSX.Element | null;
export type DiffLineType = "added" | "removed" | "unchanged";
export type DiffLineData = {
    type: DiffLineType;
    content: string;
    lineNumber?: number;
};
export interface DiffViewProps {
    lines?: DiffLineData[];
    /**
     * File path the highlighting language is inferred from (`"src/utils.ts"`
     * → TypeScript). Pass the same path you show beside the diff. An unknown
     * extension renders plain text. `language` wins when both are given.
     */
    path?: string;
    /**
     * Explicit highlighting language (`"typescript"`, `"python"`, `"tsx"`,
     * and common aliases such as `ts`, `py`, `rs`, `md`). An unknown language
     * renders plain text. Lines are highlighted one at a time, so a construct
     * that spans lines (a block comment) may color imperfectly across them.
     */
    language?: string;
    /** Show line numbers in the gutter. Default `true`. */
    showLineNumbers?: boolean;
    /** Color added and removed lines' numbers in the diff inks. Default `true`. */
    coloredLineNumbers?: boolean;
    /** Show a 3 px strip on the left edge of changed lines. Default `true`. */
    showAccentStrip?: boolean;
    style?: CSSProperties;
}
/**
 * A unified diff in the page's monospace: added lines on the success tint,
 * removed lines on the danger tint, a line-number gutter, an edge strip,
 * and syntax highlighting when `path` or `language` names the language. It
 * draws no chrome of its own; it sits in a `Section`, a `CollapsibleSection`,
 * or a grid cell.
 *
 * @example
 * ```tsx
 * <DiffView
 *   path="src/utils.ts"
 *   lines={[
 *     { type: "unchanged", content: "export function add(a: number, b: number): number {", lineNumber: 1 },
 *     { type: "removed", content: "  return a + b;", lineNumber: 2 },
 *     { type: "added", content: "  const result = a + b;", lineNumber: 2 },
 *     { type: "added", content: "  return result;", lineNumber: 3 },
 *     { type: "unchanged", content: "}", lineNumber: 4 },
 *   ]}
 * />
 * ```
 */
export declare function DiffView(props: DiffViewProps): JSX.Element;
