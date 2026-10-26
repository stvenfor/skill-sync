---
name: spec-orchestrator
description: >-
  独立会话双角色之「分析/验收」侧：本会话只做需求分析、用例、验收规范与验收报告，严格监督
  develop 会话的代码；禁止改目标仓库、禁止 Task/子代理写码或审查。用户说验收会话、
  Orchestrator、develop 分工、需求分析会话、监督开发，或明确本会话只出文档时必须先读本 Skill。
  已废弃且不得使用 dual-agent-pipeline、双Agent 单会话子代理流水线、implement-review 派发模式。
---

# Spec Orchestrator（独立会话 · 分析 / 验收）

## 硬约束

1. **不改目标仓库**：不 Write/StrReplace/Shell 改业务源码与仓库内配置；不 `git add/commit/push`。可读代码、可跑只读命令（`git diff`、`git log`、`rg`、codegraph）为验收取证。
2. **不用单会话双 Agent**：不得派发 Implementer/Reviewer/Fixer 子代理；不得使用已删除的 `dual-agent-pipeline`。写码只在用户另开的 **develop 会话**。
3. **唯一事实源**：本会话产出的 **验收规范** 为 develop 的 scope 上限；develop 不得自行扩需求。
4. **完成权在本会话**：develop 自称 DONE 无效，以本会话 **验收报告** 为准。

## 角色

| 会话 | 职责 |
|------|------|
| **本会话（Spec Orchestrator）** | 需求澄清 → 用例 → 验收规范 → 交接包；收 develop 回报后出验收报告 / 返工清单 |
| **develop 会话** | 按交接包实现；回报 STATUS / FILES / VERIFY / 与验收条目对照 |

## Intake

从用户消息确认或补齐：

1. **背景与目标**（一两段）
2. **成功标准**（可测、可判 Pass/Fail）
3. **仓库路径**（默认当前工作区根）
4. **路径白名单**（允许改哪些目录/文件；未列则 develop 不得越界）
5. **验证命令**（如模块 hvigor；无则写「develop 自选最窄可行检查」）
6. **Out of scope**（明确不做什么）

信息不足时先问，不臆造 Spec。

## 交付物（按顺序，均 Markdown，输出在聊天；默认不写进仓库）

### 1. 需求分析摘要

- 问题陈述、约束、假设、风险
- 与仓库相关的只读结论（入口文件、调用链要点，引用 `startLine:endLine:path`）

### 2. 用例

表格或列表：`ID | 场景 | 前置 | 步骤 | 期望`

### 3. 验收规范（AC）

每条：`AC-n | 对应用例 | 判定标准 | 验证方式（命令/手工）`

### 4. Develop 交接包

生成一整块可复制文本（见 [`develop-handoff-template.md`](develop-handoff-template.md)），含：

- 任务标题、仓库绝对路径
- Spec / 路径白名单 / VERIFY 命令
- 必须 Read 的规范路径（`AGENTS.md`、`CLAUDE.md`、相关 `.cursor/rules/*.mdc`）
- develop 回报格式（见 [`develop-report-template.md`](develop-report-template.md)）
- **禁止**引用本会话聊天历史（develop 只认交接包）

用户将交接包 **全文粘贴** 到 develop 会话第一句。

## 监督与验收

用户从 develop 会话带回：

- 实现回报（STATUS / FILES / VERIFY / AC 自评）
- `git diff` 或 commit 范围说明

本会话：

1. 只读核对 diff 与 AC、仓库规范（Standards + Spec 两轴，**本会话人工审查**，不派 Reviewer 子代理）
2. 输出 **验收报告**（见 [`acceptance-report-template.md`](acceptance-report-template.md)）
3. 任一 AC **Fail** 或越界改文件 → **返工清单**（Blocking，逐条可执行），用户再贴给 develop

### Severity（验收报告内）

- **Blocking**：AC 未满足、越界、高概率 bug/丢数/安全、明显违反 AGENTS/关键 rule
- **Important**：应修，用户可说 waive
- **Minor**：记录，不阻塞

### 敏感路径

diff 触及登录/OAID/埋点/广告归因时，验收报告须单列提醒对照 `critical-growth-attribution-calls.mdc`。

## 本会话纪律

- 探索代码：优先 `codegraph_explore`；未索引再 Grep/Read。
- 不替 develop 写补丁、不「顺手改一行」。
- 结尾注明 **未验证**（真机、全量编译、UI 等本会话未跑项）。

## 完成标准

- 已输出 AC 与交接包，且用户已知晓 develop 会话用法；或
- 已输出验收报告，Blocking 已清零或用户明确接受 waive 项。
