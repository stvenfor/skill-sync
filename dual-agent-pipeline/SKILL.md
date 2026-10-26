---
name: dual-agent-pipeline
description: >-
  双Agent单会话流水线：Orchestrator 派发 composer-2.5 编写子代理与 grok-4.7-medium
  审查子代理（仅 Standards + Spec 两轴），修复循环仍用 composer-2.5。用户说
  双Agent、编写+审查、implement-review、dual-agent-pipeline，或明确要求「编写后审查」时必须先读本 Skill 并严格执行。
---

# 双 Agent 流水线（单会话 · A）

Orchestrator 在本会话协调；**不亲自改业务代码**（除合并子代理报告、回答子代理提问）。编写与审查通过 **Task / Subagent** 派发，且 **必须显式指定 model**。

## 模型（写死）

| 角色 | model |
|------|--------|
| Implementer | `composer-2.5` |
| Reviewer | `grok-4.7-medium` |
| Fixer | `composer-2.5` |

省略 model 会继承会话默认模型，视为违反本 Skill。

## 审查范围（默认）

仅 **Standards** + **Spec** 两轴。默认 **不** 派发 Bugbot / security-review 子代理。用户在本轮明确要求加深审查时再追加。

## Intake（Orchestrator）

向用户确认或从消息推断：

1. **成功标准**（Spec 原文，一两段即可）
2. **路径约束**（允许改哪些目录/文件；默认当前仓库工作区）
3. **验证**（应跑的命令，如 hvigor 模块编译；无则写「实现者自选最窄可行检查」）
4. **Git**：除非用户本轮明确说 commit/提交，实现者与修复者 **不得** `git commit` / `git push`；不得 `git add` 工具目录（`.codegenie/`、`.codegraph/` 等）

多文件或步骤清晰的大改：拆成 Task 1..N，每任务独立 BASE→审查循环。单文件小改：单任务即可。

## 每任务循环

### 1. 记录 BASE

派发实现前：`BASE_SHA=$(git rev-parse HEAD)`（在目标仓库根目录执行）。

### 2. 派发 Implementer

- `subagent_type`: `generalPurpose`（或环境提供的 general-purpose 实现型）
- `model`: `composer-2.5`
- `run_in_background`: `false`
- `description`: `Implement: <短标题>`
- prompt：按同目录 [`implementer-prompt.md`](implementer-prompt.md) 填充，写入：
  - 任务描述、成功标准、路径约束、验证要求、仓库绝对路径
  - **用户规则**：子代理不继承会话 user rules；每份 prompt 必须要求其 Read [`subagent-user-rules.md`](subagent-user-rules.md)（模板已写死，Orchestrator 另附 **「本轮追加用户规则」** 原文块——把用户当轮相关 user rules / 技能约束贴进派发块）
  - 规范指针：`AGENTS.md`、`CLAUDE.md` 及本任务相关的 `.cursor/rules/*.mdc`（列路径，让子代理自行 Read）

处理实现者状态：`NEEDS_CONTEXT` → 补上下文后重派；`BLOCKED` → 拆任务或升档模型或问用户；`DONE` / `DONE_WITH_CONCERNS` → 进入审查（CONCERNS 记入 Orchestrator 备注）。

### 3. 生成审查工件

实现完成后：`HEAD_SHA=$(git rev-parse HEAD)`。

在仓库根执行（脚本在本 Skill 目录）：

```bash
bash ~/.cursor/skills/dual-agent-pipeline/scripts/review-package.sh "$BASE_SHA" "$HEAD_SHA"
```

脚本 stdout 最后一行为 **DIFF_FILE** 绝对路径。若 BASE==HEAD（无提交、仅工作区改动），改用：

```bash
bash ~/.cursor/skills/dual-agent-pipeline/scripts/review-package.sh "$BASE_SHA" "$HEAD_SHA" --working-tree
```

（见脚本用法；无提交时用工作区 diff。）

将实现者报告（STATUS / FILES / VERIFY）保存为简短文本，供审查者使用。

### 4. 派发 Reviewer

- `model`: `grok-4.7-medium`
- `run_in_background`: `false`
- `description`: `Review: <短标题>`
- prompt：按 [`reviewer-prompt.md`](reviewer-prompt.md) 填充（DIFF_FILE、成功标准、标准源文件列表、实现者报告）

Reviewer **只读**：不得改工作区、不得 commit。

### 5. Gate

- **Blocking**（任一侧）：进入修复循环，最多 **3** 轮。
- **Important**：默认修；用户本轮说 waive 则记入最终报告不修。
- **Minor / Nit**：记录，不阻塞。

修复：派发 Fixer（`composer-2.5`，[`fixer-prompt.md`](fixer-prompt.md)），仅修审查清单中的 Blocking/Important。修复后 **同一 BASE_SHA** 对当前 HEAD 重新 `review-package` 并 **重审**（新 DIFF_FILE）。

### 6. 汇总

向用户呈现：

- `## Standards` 与 `## Spec`（审查报告两节，勿合并成单一优先级列表）
- 每任务：改了什么、VERIFY 结果、轮次
- **未验证**：真机/UI/全量编译等你未跑项
- 若 diff 触及登录/OAID/埋点/广告归因：提醒对照 `.cursor/rules/critical-growth-attribution-calls.mdc`（Orchestrator 人工确认）

## Orchestrator 纪律

- 子代理 **不** 继承本会话聊天历史与 Cursor user rules；**每派一处**须在 prompt 中：① 模板里的 `subagent-user-rules.md` Read 指令；② 当轮相关的 user rules / 技能步骤（原文粘贴，勿概括成「遵守用户规则」四字）。
- 代码探索类任务：派发块写明实现者 **首步** `codegraph_explore`，VERIFY 含 `CODEGRAPH:`。
- 不在审查 prompt 里要求「不要报某类问题」——有争议在 Gate 由你裁决。
- 仓库 `AGENTS.md` 不因本 Skill 修改；个人流水线仅引用仓库规范。

## 完成标准

所有任务审查无 **Blocking**；Important 已修或用户明确 waive；Orchestrator 已输出汇总。
