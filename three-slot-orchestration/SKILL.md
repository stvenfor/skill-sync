---
name: three-slot-orchestration
description: 大型任务的三槽编排流程：最多 3 个并发 agent（默认 2 个实现 + 1 个 bug 修复），每片完成即验收、通过后才补位，禁止换 agent、绕依赖、扩槽。Use when starting a large multi-slice task, dispatching multiple agents, parallelizing features and bug fixes, or when the user mentions 三个 agent、三槽、大型任务、验收门、并行切片、派发。
---

# 三槽大型任务编排

## 何时用

- 任务能拆成 ≥3 个 slice（功能、修复、加固都算）
- 需要多个 agent 并行
- 用户说「派三个」「大型任务」「并行」「完成一个验收一个」

## 硬规则（不可协商）

1. **WIP=3**：同时最多 3 个 worktree / agent。不是「大约 3 个」。
2. **槽位钉死 `agent + model`**：派发前写进 Task；启动后先核对终端页脚的 agent/model，不一致立即停，不替补。
3. **不绕依赖**：deps 未验收就不派；宁可空槽，不得 `task-update --status ready` 绕过。
4. **完成 ≠ 验收**：worker 报完成只进入 `Verifying`，不释放槽位。
5. **验收由 coordinator 亲自做**：复跑 build/test/lint，不能只采信 worker 自述。
6. **worker 不 commit/push**：`git add/commit/push` 由人执行。
7. **破坏性动作单独 gate**：DDL、删数据、密钥、依赖升级、跨仓改动，必须人批。
8. **重试不算新槽**：同一 slice 失败先修 agent 配置，最多重试 1 次；重试不扩大并发。

## 角色分配

默认 3 槽：

| 槽 | 角色 | 选片规则 |
|---|---|---|
| A | 实现 | 无依赖或依赖已验收的最大 slice |
| B | 实现 | 与 A 文件不重叠、可并行的 slice |
| C | **bug 修复** | P0/P1、≤1 文件或 ≤30 行、必须带回归测试 |

按 wave 轮换：一波 3 片验收完后，下一波重新按「2 实现 + 1 bug」补位。没有 bug 时 C 槽做最小加固片（测试/观测/文档），不空转。

## 流程

0. **Brief**：每片写清 `本轮 ONLY / 不做 / 验收 / 文件白名单 / 验证命令 / 证据`，人批后才开工。
1. **DAG**：标 deps，算出 Ready 集合。
2. **状态板**：`Ready → Running → Verifying → Accepted → Merged → Blocked`。
3. **启动 3 槽**：只从 Ready 取 3 个，记录 `taskId / dispatchId / agent / model / worktree`。
4. **完成信号**：worker 必须发 `worker_done`（带 dispatchId）。只打印正文不算；coordinator 复核后可 `task-update --status completed`。
5. **验收门**（阻塞）：全部通过才 `Accepted`，然后释放槽位。
6. **合并**：每 wave 合并一次，人执行 commit/push；合并后复跑 `go build all` + 定向测试 + lint。
7. **补位**：从 Ready 取下一片，回到第 3 步。
8. **复盘**：记录 agent 实际型号、失败重试、验收结论。

## 验收清单（缺一不可）

- [ ] `git diff` 仅命中白名单；黑名单零改动
- [ ] coordinator 复跑：build、定向测试、lint、机检脚本
- [ ] 状态词只用 `Migrated / Degraded / Placeholder / Deferred / Partial`，并写 note
- [ ] acceptance-record 存在且证据可复现（命令 + 原始输出）
- [ ] 无密钥、无二进制、无 `go.mod/go.sum` 越界
- [ ] 冲突/编号（如 inventory 条目）已对齐
- [ ] worker 未 commit/push

## 命令模板（Orca）

```bash
# 1) worktree（每槽一个，复用优先）
orca worktree create --name <slot> --repo path:<repo> --base-branch main --branch maoqian/<slot>

# 2) 终端：钉死 agent（model 用该 CLI 已配置的 A 级型号）
orca terminal create --worktree path:<worktree> --command codebuddy
orca terminal create --worktree path:<worktree> --command "cline -i"

# 3) 任务与派发
orca orchestration task-create --run <run> --task-title "<title>" --spec-file <spec>
orca orchestration dispatch --task <taskId> --to <term> --inject
orca terminal send --terminal <term> --text "$(cat <spec>)" --enter   # inject 常不落 prompt，必补

# 4) 收口
orca orchestration task-update --id <taskId> --status completed --result "<verdict>"
orca orchestration worker-stop --dispatch <dispatchId>
```

## 失败处理

- **agent 起不来**：先修配置（凭据/版本），再原槽重试；禁止换别的 agent 顶上。
- **worker 不发 worker_done**：coordinator 复核后手工收口，并记一次流程缺陷。
- **验收不过**：打回同一槽，附具体失败命令与期望；不新开槽。
- **超时**：`worker-stop`，任务回 `Ready`，换到下一波，不扩并发。

## 反模式（本次踩过）

- 一次开 10 个 worktree，事后批量验收
- opencode/codex 失败后随手换 Qoder/CodeBuddy，没问人
- 绕过 deps 把 h4–h8 全部置 ready
- 只信 worker 的「全绿」，未亲自复跑
- 把 worker 正文里的 `worker_done` 当成已上报
