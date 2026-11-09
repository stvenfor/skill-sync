import type { JSX } from "react";
import { type ButtonVariant } from "./controls.js";
export interface ReplyButtonProps {
    /** The option as the button shows it; also the reply when `reply` is absent or blank. */
    label: string;
    /** The text the reply is filled in with, when it should say more than the label. */
    reply?: string;
    /** Same as `Button`'s: `primary` for the one option a row leads with. */
    variant?: ButtonVariant;
}
/**
 * A reply option. Pressing it opens the viewer's messenger with the reply
 * filled in, for the viewer to send. It shows disabled, its label still read,
 * where the host delivers no replies or the text it would send runs past 300
 * characters.
 *
 * @kitUnlisted Only a host that delivers replies teaches it, in its own prompt.
 */
export declare function ReplyButton({ label, reply, variant }: ReplyButtonProps): JSX.Element | null;
