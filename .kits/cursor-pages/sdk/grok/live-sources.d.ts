import { type JSX } from "react";
/** A JSON value as a connector returned it. */
export type SourceJson = string | number | boolean | null | readonly SourceJson[] | {
    readonly [key: string]: SourceJson;
};
/**
 * What `useSource` returns: the current value and where it came from.
 * `fresh` is false while the page shows the authoring snapshot and true once
 * a refresh replaced it; `asOf` stamps the value either way; `error` is a
 * short reason when the last refresh failed and the snapshot stayed.
 */
export interface LiveSource<T = SourceJson> {
    readonly value: T;
    readonly asOf: string;
    readonly fresh: boolean;
    readonly error?: string;
}
/**
 * The current value of a declared source. Pass the id as a string literal:
 * the compiler checks it against the page's `cursor-canvas-sources` block
 * and refuses a page that reads a source it does not declare. The type
 * argument is the author's promise about the value's shape, the same one
 * the block's `shape` note records; it is not checked at runtime.
 *
 * @example
 * ```tsx
 * const bugs = useSource<Issue[]>("openBugs");
 * <Table rows={bugs.value.map(...)} />
 * <SourceStamp source={bugs} />
 * ```
 */
export declare function useSource<T = SourceJson>(id: string): LiveSource<T>;
export interface SourceStampProps {
    /** The source whose stamp to show, as `useSource` returned it. */
    source: LiveSource<unknown>;
}
/**
 * One quiet caption line saying how current a source's value is: `Updated
 * 12 s ago` once a refresh landed, `As of Oct 19, 2026, 3:04 PM` while the
 * page shows its authoring snapshot. After a refresh that failed, the
 * stamp keeps the snapshot date and a quiet status pill beside it says the
 * page is showing the last value (or which app to connect). It ticks so
 * the relative age stays true while the page is open, and its tooltip is
 * always the exact time of the read. Put it under the block that shows
 * the value.
 */
export declare function SourceStamp({ source }: SourceStampProps): JSX.Element;
