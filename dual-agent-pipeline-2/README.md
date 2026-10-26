# dual-agent-pipeline（本机个人）

单会话：Orchestrator → `composer-2.5` 编写 → `grok-4.7-medium` 审查（Standards + Spec）→ 必要时 `composer-2.5` 修复。

## 新会话怎么用

1. 新开 Agent 聊天（本 Skill 在 `~/.cursor/skills/`，不进 Dubbing 仓库）。
2. 第一句带上触发词，例如：**双Agent**：\<你的需求\>，成功标准是 …
3. 或写：**implement-review** / **编写+审查**。

Agent 应读取 `SKILL.md` 并按 Task 派发子代理。

## 文件

| 文件 | 作用 |
|------|------|
| `SKILL.md` | 编排主流程 |
| `implementer-prompt.md` | 编写子代理模板 |
| `reviewer-prompt.md` | 审查子代理模板 |
| `fixer-prompt.md` | 修复子代理模板 |
| `subagent-user-rules.md` | 子代理须 Read 的用户规则摘要 |
| `scripts/review-package.sh` | 生成审查用 diff 文件 |

## 同步到其他机器

复制整个目录到对方 `~/.cursor/skills/dual-agent-pipeline/`，或 dotfiles 里 symlink。
