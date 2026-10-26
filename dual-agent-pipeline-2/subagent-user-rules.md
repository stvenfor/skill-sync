# 子代理继承规则（双 Agent 派发时与会话 user rules 对齐）

子代理**不**继承 Orchestrator 聊天历史；派发 prompt 要求你 **Read 本文件全文** 并遵守。与仓库 `AGENTS.md` / `CLAUDE.md` 冲突时以**仓库**为准。

## 执行与环境

- 在本机真实环境跑命令、读代码；失败换思路重试，不要臆测。
- 回复语言与任务描述一致（中文任务用中文回报）。
- 结合任务意图做最小完整改动；不顺手重构、不加未要求抽象。

## CodeGraph（强制，探索/扫描代码类任务）

- 工作区已索引时：**第一个**代码情报动作必须是 MCP `user-codegraph` 的 `codegraph_explore`（自然语言或符号名），再决定是否 Read 单文件。
- **禁止**在未尝试 codegraph 的情况下，用 Grep/Read 做大范围「找入口、跟调用链」。
- 若返回「项目未索引」：回报中写明，再改用 Grep/Read；**不要**提交 `.codegraph/`。
- 回报 **VERIFY** 须含一行：`CODEGRAPH: <问了什么> → <命中/未索引/空>`。

## Git

- 除非 Orchestrator 在本任务**明文**允许 commit/提交，否则不得 `git commit` / `git push` / `git add`。
- 不得 stage `.codegenie/`、`.codegraph/`、build 产物、`node_modules/`、`oh_modules/` 等。

## 鸿蒙本仓库（Dubbing）

- 遵守 `[REPO_ROOT]/AGENTS.md`、`CLAUDE.md`；ArkTS 改动前读 arkts 相关 `.cursor/rules`。
- 跨工程目录只读；改动仅当前仓库。
- 配音主流程文档维护：`feature/dubbing/docs/DUBBING_PAGE.md` 与 `DUBBING_MAIN_FLOW.md` 分工（链路 vs 需求/Bug 索引）。

## 写作与回报

- 代码引用用 `startLine:endLine:filepath`（给用户看时）；子代理回报以 STATUS/FILES/VERIFY 为主，少废话。
- 结尾可注未验证项与风险（真机、全量编译等）。
- Commit message / PR：用户明确要求才做；中文说明；无 `Co-authored-by: Cursor`。

## Orchestrator 追加块

派发 prompt 中若有 `## 本轮追加用户规则`，优先级与本文件相同，必须一并遵守。
