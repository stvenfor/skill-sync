import type { CSSProperties, JSX, ReactNode } from "react";
import { type CursorPageCategory } from "./theme.js";
/** The order segments without a `color` take hues in, so the same index lands on the same hue. */
export declare const usageCategorySequence: readonly CursorPageCategory[];
export interface UsageBarSegment {
    /** Stable identifier, the segment's React key. */
    readonly id: string;
    /** The segment's share of `total`; a non-finite or non-positive value is 0. */
    readonly value: number;
    /** The segment's hue; by default the next one in `usageCategorySequence`. */
    readonly color?: CursorPageCategory;
}
export interface UsageBarProps {
    /** Segments left to right, each as wide as its `value`'s share of `total`. */
    readonly segments: readonly UsageBarSegment[];
    /** The whole bar; what the segments leave of it is the quiet remainder. */
    readonly total: number;
    /** A short label above the bar, at the start. */
    readonly topLeftLabel?: ReactNode;
    /** A short label above the bar, at the end. */
    readonly topRightLabel?: ReactNode;
    readonly style?: CSSProperties;
}
/**
 * A fixed budget split into categories: a thin bar of proportional
 * segments in the category hues, the unused rest in the neutral tint, and
 * an optional line of labels above it. For a context window, a quota, or
 * storage.
 *
 * @example
 * ```tsx
 * <UsageBar
 *   total={120_000}
 *   topLeftLabel="64% full"
 *   topRightLabel="76.8K / 120K tokens"
 *   segments={[
 *     { id: "system", value: 8_000, color: "gray" },
 *     { id: "tools", value: 24_000, color: "purple" },
 *     { id: "conversation", value: 44_800, color: "blue" },
 *   ]}
 * />
 * ```
 */
export declare function UsageBar(props: UsageBarProps): JSX.Element;
