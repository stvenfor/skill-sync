import { type JSX } from "react";
export interface ImageProps {
    /**
     * `asset:<name>`: a picture uploaded beside the page (the asset tool
     * returns this exact string). A `data:image/...` URL paints too, for a
     * tiny icon. Any other URL, a web address included, is never fetched and
     * shows the `alt` text in its place.
     */
    src: string;
    /** What the picture shows, in a sentence: read aloud, and shown in the picture's place until it loads or when it is missing. */
    alt: string;
    /** A line under the picture, in the subtext style. */
    caption?: string;
    /** How the picture fills a box of a set `height`: `contain` keeps all of it (default), `cover` fills the box and crops. */
    fit?: "contain" | "cover";
    /** The picture's width: a CSS width (`320`, `"50%"`). Unset, it spans the column and never exceeds it. */
    width?: number | string;
    /** A fixed height in px; unset, the picture keeps its own proportions. */
    height?: number;
    /**
     * The picture's own proportions, as `width / height` (`1.5`, `"1200/800"`,
     * `"16 / 9"`), so its box is the right shape before it loads and the page
     * does not shift when it does. Unneeded for an uploaded asset the host has
     * measured; the measurement wins when both are present.
     */
    ratio?: number | string;
}
/**
 * A picture on the page: an uploaded asset named `asset:<name>`, with an
 * optional caption under it. It paints once the host hands the frame the
 * picture's bytes. Until then its box is already the picture's shape when
 * the host knows the picture's size, so nothing below moves when it lands,
 * and a blurred few-pixel stand-in, when the host has one, breathes in the
 * box; otherwise the `alt` text waits on a quiet tinted box, so a viewer
 * always learns what the picture shows. Bytes that fail to decode leave the
 * alt text up, marked broken, until the host hands over others. Never a web
 * address: the frame fetches nothing from the internet, so a web picture
 * must be downloaded and uploaded as an asset first.
 */
export declare function Image(props: ImageProps): JSX.Element;
