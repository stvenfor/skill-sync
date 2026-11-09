import type { CSSProperties, JSX, ReactNode } from "react";
/** The ink of a `Stat`'s figure: `success`, `danger`, `warning`, or `info` (the accent). */
export type StatTone = "success" | "danger" | "warning" | "info";
export interface StatProps {
    /** The figure: a number, a percentage, a short string. */
    value: ReactNode;
    /** The label under the figure. */
    label: string;
    /** A tone for the figure; left out, it is the primary ink. */
    tone?: StatTone;
    style?: CSSProperties;
}
/**
 * One figure with its label under it, in the page's metric type. For one or
 * two figures beside a primary artifact; a strip of them is `Metrics`.
 *
 * @example
 * ```tsx
 * <Grid columns={2}>
 *   <Stat value="12" label="Failing checks" tone="danger" />
 *   <Stat value="3" label="Services" />
 * </Grid>
 * ```
 */
export declare function Stat(props: StatProps): JSX.Element;
