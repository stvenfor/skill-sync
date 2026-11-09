/**
 * Public API for authoring `.canvas.tsx` files via `cursor/pages`.
 *
 * A canvas built with this kit is a Grok page, as `grok/canvas` draws one,
 * with the blocks an engineering workflow needs on top: a unified diff and
 * its `+N / -N` counts, a usage bar and the swatches that key it, an
 * agent's task list, a borderless disclosure row, a single figure, and an
 * inline code span; and the host hooks that persist state across reloads
 * and ask the IDE to open an agent, a chat, or a file. Everything from
 * `grok/canvas` is here under the same names and styled the same way;
 * `useCursorPageTheme()` is `useGrokTheme()` plus `diff` tones and a
 * `category` palette. Wrap the canvas in one `Page`, and never hardcode
 * colors or fonts.
 */
export * from "../grok/index.js";
/** Diffs: the unified diff body, and the `+N` / `-N` pair. */
export type { DiffLineData, DiffLineType, DiffStatsProps, DiffViewProps } from "./diff.js";
export { DiffStats, DiffView } from "./diff.js";
/** A fixed budget as a segmented bar, and the swatch that keys a category. */
export type { UsageBarProps, UsageBarSegment } from "./usage.js";
export { UsageBar, usageCategorySequence } from "./usage.js";
export type { SwatchProps } from "./swatch.js";
export { Swatch } from "./swatch.js";
/** An agent's task list, bare or in a folding card. */
export type { TodoItem, TodoListCardProps, TodoListProps, TodoStatus } from "./todo.js";
export { TodoList, TodoListCard } from "./todo.js";
/** A borderless disclosure row that nests into a tree. */
export type { CollapsibleSectionProps } from "./collapsible.js";
export { CollapsibleSection } from "./collapsible.js";
/** One figure with its label. */
export type { StatProps, StatTone } from "./stat.js";
export { Stat } from "./stat.js";
/** An inline code span. */
export type { CodeProps } from "./code.js";
export { Code } from "./code.js";
/** Host state and actions. */
export type { CanvasAction, CanvasOpenFileSelection, SetCanvasState } from "./host.js";
export { useCanvasAction, useCanvasState } from "./host.js";
/** Tokens. */
export type { CursorPageCategory, CursorPageDiffTones, CursorPageTheme } from "./theme.js";
export { useCursorPageTheme } from "./theme.js";
//# sourceMappingURL=index.d.ts.map