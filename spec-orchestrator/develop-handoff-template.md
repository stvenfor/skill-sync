# Develop 交接包（由 Spec 会话生成，全文粘贴到 develop 会话）

你是 **develop 会话**：只实现下方任务，不扩 scope。你不继承 Spec 会话聊天历史；**仅**以本块为据。

## 仓库

`[REPO_ROOT]`

## 任务

`[TASK_TITLE]`

`[TASK_DESCRIPTION]`

## 成功标准（Spec）

```
[PASTE_AC_AND_SUCCESS_CRITERIA]
```

## 路径白名单

```
[ALLOWED_PATHS]
```

## 验证（必须执行并回报结果）

```
[VERIFY_COMMANDS]
```

## 规范（实现前 Read）

- `[REPO_ROOT]/AGENTS.md`
- `[REPO_ROOT]/CLAUDE.md`
- `[RULE_PATHS]`

HarmonyOS / ArkTS：涉及类型与对象字面量时 Read 项目 arkts 相关 rule。

## Git

除非本块写明允许 commit/提交，否则不得 `git commit` / `git push` / `git add`。不得 stage `.codegenie/`、`.codegraph/`、build、`oh_modules/` 等。

## 回报格式（完成后一次性回复）

```
STATUS: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

FILES:
- path — 说明

VERIFY:
- 命令 — 结果

AC_SELF_CHECK:
- AC-1 — Pass/Fail — 证据一行
- ...

CODEGRAPH: <问了什么> → <命中/未索引/空>

CONCERNS: （可选）
```

不要宣布「已验收」；验收由 Spec 会话出报告。
