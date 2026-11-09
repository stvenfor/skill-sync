import type { CSSProperties, JSX, ReactNode } from "react";
export interface CodeProps {
    children?: ReactNode;
    style?: CSSProperties;
}
/**
 * An inline `<code>` span for an identifier, a file name, or a short
 * snippet, in the page's monospace on the neutral tint. It is sized in
 * `em`, so it follows the text around it, inside a `Text` or a table cell.
 *
 * @example
 * ```tsx
 * <Text>Run <Code>npm install</Code> to get started.</Text>
 * ```
 */
export declare function Code({ children, style }: CodeProps): JSX.Element;
