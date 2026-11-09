import { type CSSProperties, type JSX, type ReactNode } from "react";
export interface CollapsibleSectionProps {
    /** The row's title, beside the chevron. */
    title: string;
    /** A small mark between the chevron and the title, e.g. a `Swatch`. */
    leading?: ReactNode;
    /** A count after the title, e.g. how many children. */
    count?: number;
    /** What sits at the end of the row: a figure, a `Status`, a `DiffStats`. */
    trailing?: ReactNode;
    /** The body, shown when open. */
    children?: ReactNode;
    /** Open at first; default closed. */
    defaultOpen?: boolean;
    style?: CSSProperties;
}
/**
 * A borderless disclosure row: a chevron, an optional leading mark, a
 * title, a count, and a trailing slot, over a body that folds open. Rows
 * nest, and the body is inset under the title, so a stack of them reads as
 * a tree. For a bordered fold, put a `TodoListCard` or a `Section` in a
 * `Grid` instead.
 *
 * @example
 * ```tsx
 * <CollapsibleSection
 *   title="Tools"
 *   count={4}
 *   leading={<Swatch color="purple" />}
 *   trailing="12.3k"
 * >
 *   <CollapsibleSection title="Grep">
 *     <Text>Search results.</Text>
 *   </CollapsibleSection>
 * </CollapsibleSection>
 * ```
 */
export declare function CollapsibleSection(props: CollapsibleSectionProps): JSX.Element;
