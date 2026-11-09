import type { CSSProperties, JSX } from "react";
import { type CursorPageCategory } from "./theme.js";
export interface SwatchProps {
    /** The category's hue; the same name colors its `UsageBar` segment. */
    color: CursorPageCategory;
    style?: CSSProperties;
}
/**
 * A filled 24 px rounded square in a category hue: the leading mark of a
 * category row, or the `leading` slot of a `CollapsibleSection`. The same
 * `color` tints the category's `UsageBar` segment, so the two read as one.
 *
 * @example
 * ```tsx
 * <CollapsibleSection title="Tools" count={4} leading={<Swatch color="purple" />}>
 *   <Text>Tool calls go here.</Text>
 * </CollapsibleSection>
 * ```
 */
export declare function Swatch({ color, style }: SwatchProps): JSX.Element;
