import { type CSSProperties, type JSX } from "react";
export type TodoStatus = "pending" | "in_progress" | "completed" | "cancelled";
export interface TodoItem {
    readonly id: string;
    readonly content: string;
    readonly status: TodoStatus;
}
export interface TodoListProps {
    todos?: readonly TodoItem[];
    /** Items drawn in the secondary ink even when in progress. */
    dimmedTodoIds?: ReadonlySet<string>;
    /** Called when a row is pressed; the whole row is the button. */
    onTodoClick?: (todo: TodoItem) => void;
    style?: CSSProperties;
}
/**
 * An agent's task list: one row per item with a status mark (pending, in
 * progress in the accent, completed in the success ink, cancelled) and
 * wrapping text; a finished item is struck through. Each row is a button,
 * so `onTodoClick` can select or navigate. For a read-only checklist of
 * recorded status, use `Checklist`.
 *
 * @example
 * ```tsx
 * <TodoList todos={items} onTodoClick={(todo) => setActiveId(todo.id)} />
 * ```
 */
export declare function TodoList({ todos, ...rest }: TodoListProps): JSX.Element | null;
export interface TodoListCardProps {
    todos?: readonly TodoItem[];
    dimmedTodoIds?: ReadonlySet<string>;
    /** Open at first; default `true`. */
    defaultExpanded?: boolean;
    onTodoClick?: (todo: TodoItem) => void;
    style?: CSSProperties;
}
/**
 * A `TodoList` in a bordered, folding card whose header counts progress
 * (`3 of 7 done`). The header is the toggle.
 *
 * @example
 * ```tsx
 * <TodoListCard todos={items} defaultExpanded onTodoClick={(todo) => console.log(todo.id)} />
 * ```
 */
export declare function TodoListCard({ todos, ...rest }: TodoListCardProps): JSX.Element | null;
