/**
 * Setter for `useCanvasState`. Accepts either a new value or an updater
 * function that receives the previous value.
 */
export type SetCanvasState<T> = (action: T | ((prev: T) => T)) => void;
/** Where in a file `openFile` lands: a line, or a range of lines and columns, 1-based. */
export type CanvasOpenFileSelection = {
    startLineNumber: number;
    startColumn?: number;
    endLineNumber?: number;
    endColumn?: number;
};
/**
 * An action a page can ask the host IDE to take; see `useCanvasAction` for
 * what each one does.
 */
export type CanvasAction = {
    type: "openAgent";
    agentId: string;
} | {
    type: "newComposerChat";
    userPrompt?: string;
} | {
    type: "openFile";
    path: string;
    selection?: CanvasOpenFileSelection;
};
/**
 * Persistent state hook for canvas applications. Works like `React.useState`
 * but the value survives rebuilds, reloads, and IDE restarts — it is stored
 * in a `.canvas.data.json` sidecar file next to the canvas source.
 *
 * Each key is a unique string chosen by the canvas author. Keys are stable
 * regardless of hook call order or component tree structure.
 *
 * @param key - Unique string identifier for this piece of state.
 * @param defaultValue - Value returned when no persisted value exists for `key`.
 * @returns A `[value, setValue]` tuple, same shape as `React.useState`.
 *
 * @example
 * ```tsx
 * function Counter() {
 *   const [count, setCount] = useCanvasState("count", 0);
 *   return <Button onClick={() => setCount(c => c + 1)}>{count}</Button>;
 * }
 * ```
 */
export declare function useCanvasState<T>(key: string, defaultValue: T): [T, SetCanvasState<T>];
/**
 * Returns a stable `dispatch` function for triggering IDE actions from
 * canvas buttons. Actions are fire-and-forget — the canvas does not
 * receive a response, and a page shown outside the IDE drops them.
 *
 * ## Available actions
 *
 * **`openAgent`** — Navigate the IDE to an agent conversation.
 * `agentId` is the conversation UUID (the filename stem from the
 * `agent-transcripts/` directory). Works for both local and
 * cloud/background agents in Glass and classic IDE modes.
 *
 * **`newComposerChat`** — Open a new local agent chat with the
 * dispatching canvas file as an @mention. Optional `userPrompt` is
 * appended after the mention. The canvas file is resolved from the
 * action route's `canvasId`; do not pass the path from canvas UI.
 *
 * **`openFile`** — Open an existing workspace file in the host IDE.
 * `path` may be workspace-relative or absolute. Optional `selection`
 * follows VS Code editor line/column fields.
 *
 * @example
 * ```tsx
 * function AgentLink({ agentId, title }: { agentId: string; title: string }) {
 *   const dispatch = useCanvasAction();
 *   return (
 *     <Button onClick={() => dispatch({ type: "openAgent", agentId })}>
 *       {title}
 *     </Button>
 *   );
 * }
 * ```
 */
export declare function useCanvasAction(): (action: CanvasAction) => void;
