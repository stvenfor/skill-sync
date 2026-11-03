## A. 执行总则（CODE / 返工必遵）

> 角色名可随工程约定替换：**主控**（需求分析、拆 TASK、写 REVIEW、验收）↔ **执行**（读 TASK、白名单内写码、自测、写 RESULT）。两者无 API 直连时，用仓库联动总线 `ACTIVE.md` 当信号灯。

### A.0 联动入口（每次会话先做）

路径约定（相对鸿蒙仓）：`.agent-bridge/tasks/ACTIVE.md`；TASK / RESULT / REVIEW 同在 `.agent-bridge/` 下（或工程等价桥目录）。

每次用户说「联动」「开工」或任意新消息时：

1. 确认本总则已加载。
2. 读 `ACTIVE.md` YAML：
   - **`DISPATCHED`** → 立即读 `task_path`，按该 TASK 全量执行；**不要**等用户再贴 `TASK-00x` 路径。
   - **`IN_REVIEW`** → 已交卷；仅当主控改回 `DISPATCHED`（返工）时再动代码。
   - **`IDLE`** → 无派单；不擅自大改，可提示「等主控派发 ACTIVE」。
   - **`BLOCKED`** → 读 `note`，向用户说明阻塞点。
3. 交卷后：写完 `result_path` 对应 RESULT，**仅**把 ACTIVE `status` 改为 **`IN_REVIEW`**（勿改 `task_id` / `task_path` / `note`）。

用户侧：执行侧说「联动」即可；主控侧新建/派发 TASK 后更新 ACTIVE（或跑 `dispatch.sh <NNN> [note]`）。

### A.1 角色边界

| 执行做 | 执行不做 |
|------|--------|
| 读 TASK → 在白名单内写码 → 自测 → 写 `RESULT-<NNN>.md` | 扩 scope、擅自改产品/UI 视觉期望、替主控做需求决策 |
| 遵守 `AGENTS.md`、`CLAUDE.md`、TASK 列出的 `.cursor/rules/*.mdc` | 越界改 `entry/`、其他 `feature/*`、登录/OAID/埋点/广告归因（除非 TASK 白名单写明） |
| 需求不清时 RESULT 标 `BLOCKED` +「待确认」 | 猜产品意图、静默大重构 |

### A.1.1 禁瞎猜 / 禁默认实现（强制 · 详见 §I）

- 执行侧 **不得**在证据不足时写业务/UI；只能 `BLOCKED` + 停问。
- 主控见 RESULT 缺 `NO_GUESS` / `NO_DEFAULT` / 相关 `EVIDENCE_*`，或 diff 含 §I 黑名单占位 → **REJECTED**。
- 「先实现再问」一律视为违规，即使观感接近截图。

**文件所有权：** `TASK` / `REVIEW` 由主控维护；`RESULT` 由执行维护。勿改 TASK 核心需求（可选把 TASK 状态标 `IN_PROGRESS`）。

跨端同步流水线中的粗分：

| 角色 | 负责 |
|------|------|
| 主控 / PM / code review | 范围、CLARIFY、映射表、PROMPT、STAGE_A、DEVICE 验收、REVIEW |
| 执行 / code develop | CODE、自测 VC、RESULT、按 REVIEW 返工 |
| 截图轨 | Android shots-manifest 跑通与索引（可主控派或专用脚本） |

### A.2 Codegraph 检索（强制优先 · 提速）

- **凡找定义、调用链、改前影响面、定位落点：必须先走 codegraph**（MCP `codegraph_explore` 或仓内等价工具），**禁止**一上来全仓 `grep` / 批量 `Read` 代替。
- **提速纪律：** 一次问清符号与 blast radius → **只 Read 命中路径** → 仍不够再对 **≤3 个路径** 做窄 `rg`。禁止「先扫全仓再想」。
- **例外（须写入 RESULT）：** 工具报未索引 / 文件 stale / codegraph 不可用——写明原因后，才允许对该范围退回窄 `rg`/`Read`。
- 每次交卷在 **RESULT** 与聊天回报强制写 **CODEGRAPH**：`<查询摘要> → 命中 / 未索引 / 空`；缺此项主控可直接 REJECTED。
- 对照端（iOS/Android/Flutter）只读勘察可用窄 `rg`/`Read`；**鸿蒙改码前影响面仍必须先 codegraph**。

### A.3 Ponytail 写码（强制优先）

- **进入改码即启用 Ponytail：** 最小 diff；能删不加；**优先复用**现有 helper / 组件 / 请求与鉴权；不顺手重构相邻代码；不加未要求的抽象、配置、一层 wrapper。
- 修 bug / 修编译：**先 codegraph 查被改符号的全部调用方**；能在业务侧局部修则局部修（公共层改动另见 A.3.1）。
- **ArkTS：** 改 `*.ets` 前 Read 仓内 `arkts-no-any-unknown`（或等价）规则。
- 与 Ponytail 冲突时以 **`AGENTS.md` / `CLAUDE.md`** 为准。
- 单次改动 **>3 个文件** → RESULT 用一句话说明「为何不能更小」。
- 跨端转码仍遵守「转码原则」：映射/状态机，不是字面翻译；禁止镜像搬目录。
- 交卷可写 **PONYTAIL：** 一行（复用了哪些现成封装 / 为何必须新写）。

### A.3.1 公共组件 / 公共代码（硬门）

- **默认禁止**修改公共层，包括但不限于：`common/`、跨 `feature/*` 共享组件、公共请求/鉴权封装、全局主题/导航/列表/弹层等已封装公共 UI、全局工具与基类（具体边界以仓内 `AGENTS.md` / `PROJECT_MAP.md` / 模块约定为准）。
- **优先使用**项目里已有封装：对照点落点应落在业务 `feature` 内组合调用，禁止为「顺便对齐」去改公共实现。
- **仅当**当次 TASK / 对照表白名单**显式写出**必须改的公共文件路径时，才允许改公共层；且须同时满足：
  1. **无回归：** 不得影响其它原有功能与既有 UI 观感；改前用 codegraph 列出调用方，改后按调用面做最小验证；
  2. **能局部解决就不改公共：** 业务侧 wrapper、局部样式、feature 内组件能覆盖的，禁止动公共层；
  3. **交卷强制 `PUBLIC_IMPACT` 专段**（缺则 REJECTED）：改了哪些公共符号与路径、主要调用方、为何不能复用/包装解决、对其它模块**功能**与 **UI** 的影响（含无影响时的判定依据）、验证步骤与结果。
- 未经白名单改公共文件，或改了公共层却无 `PUBLIC_IMPACT` → 主控直接 **REJECTED**。

### A.4 Git 与敏感目录

- **默认禁止** `git commit`、`git push`。
- **禁止** `git add`：`.codegenie/`、`.codegraph/`、`oh_modules/`、`build/`、`node_modules/`、证书/密钥、签名材料、**以及 `~/Desktop/android-shots/`（及任何截图产物目录）**等（与根目录 `AGENTS.md`、`git-*` 规则一致）。
- 仅当 **当次 TASK 约束明确允许** 且路径在 **白名单** 内时，可对源码 `git add`（仍不 commit，除非 TASK 写明可提交）。
- **跨工程只读：** 对照 iOS/Flutter/Android 等只能读，改码只在目标鸿蒙仓。
- 不得把签名、密钥、内部地址贴进对话、新文件或提交。

### A.5 单次 TASK 流程

1. 从 **`ACTIVE.md`** 解析当次 **`task_path`**，只做该 TASK 的步骤、验收（VC）、约束、白名单。
2. 实现前 Read：`AGENTS.md`、`CLAUDE.md`；TASK 若列出其他 rule，一并 Read。
3. 复制 **`templates/RESULT.md`** → **`tasks/RESULT-<NNN>.md`**。
4. 按 TASK 的 **VC1、VC2…** 在终端自测，RESULT 逐条贴命令与关键输出。
5. RESULT 状态：**`NEEDS_REVIEW`**（或 `BLOCKED` / `DONE_WITH_CONCERNS`）。
6. 将 **`ACTIVE.md`** 的 `status` 改为 **`IN_REVIEW`**；告诉用户：**「已交卷，请回主控验收（联动总线已 IN_REVIEW）。」**

**验收与返工：** 主控写 `reviews/REVIEW-<NNN>.md`，并把 ACTIVE 置 `IDLE`（通过）或 `DISPATCHED`+note（返工）。`REJECTED` 时只按 REVIEW 的**明确改进指令**改并更新 RESULT，建议 ≤3 轮；禁止「再优化一下」式空指令。

跨端模块同步时，单次 TASK 通常对应一个**切片**（壳 / 主路径 / 分支 / 视觉 triage），禁止整模块糊成一单。视觉/弹框/图标切片还须先完成 **§B 对照点表**。

### A.6 聊天交卷格式（每次任务结束）

```text
STATUS: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT

TASK: TASK-<NNN>
RESULT: .agent-bridge/tasks/RESULT-<NNN>.md

VERIFY: <当次 TASK 要求的验证命令> → 结果摘要

CODEGRAPH: <查询摘要> → 命中 / 未索引 / 空

PONYTAIL: <复用了哪些封装 / 为何必须新写>（一行）

PUBLIC_IMPACT: 无公共层改动 | 有 → 见 RESULT 专段（路径/调用方/为何必须/功能与 UI 影响/验证）

FILES: （若有）路径 — 一行说明
```

不要宣布「已验收」；验收权在主控。跨端 DEVICE 结论写在 RESULT/REVIEW，不在交卷聊天里冒充结案。对照实现交卷须附 **§B 同表回勾**。

### A.7 工程索引（按需查阅）

典型鸿蒙仓（路径随仓调整；TASK 指定时再精读）：

| 用途 | 位置 |
|------|------|
| 模块与路由约定 | `AGENTS.md`、`PROJECT_MAP.md` |
| 构建与依赖 | `build-profile.json5`、各模块 `oh-package.json5` |
| 路由入口 | `entry/src/main/ets/pages/pagesMap.ets` |
| 深链 | `common/src/main/ets/utils/schemeMap.ets` |
| 请求 | `common/src/main/ets/api/request.ets` |
| 架构/模块报告 | `docs/PROJECT_ARCHITECTURE.md`、`docs/module-reports/`（若有） |
| 联动总线 | `.agent-bridge/tasks/ACTIVE.md`、`tasks/TASK-*.md`、`templates/` |
| 规则 | `.cursor/rules/*.mdc`（按任务触发，不整批加载） |

定位代码优先 **codegraph**，再窄 `rg` / `Read`。业务定位可先 `rg` `PROJECT_MAP.md` 命中附近小节，不默认全文加载。

### A.8 首次接入确认语

读完本 skill（尤其 **A. 执行总则** 与 **B. 对照点表**）后，执行侧首次回复：

**已理解：总则长期有效；每次先读 ACTIVE 联动；检索强制先 codegraph（禁先全仓 grep），写码强制 Ponytail；默认禁改公共组件/公共代码、优先复用，必要改动须白名单 + PUBLIC_IMPACT；对照点先只读出表，禁系统替代设计稿；**禁瞎猜/禁默认实现（§I）**；并行时一切片一 worktree，合后再 DEVICE。**

之后用户说 **「联动」** 或发任意消息时，先执行 **A.0** 再决定是否改代码。

### A.9 任务队列说明

- **权威队列：** 以 **`tasks/ACTIVE.md`** 为准；**勿**扫仓库自选 `TASK-*.md` 开干。
- 主控派发记录见 ACTIVE 的 `task_id` / `task_path` / `note`。
- 状态机：`IDLE` → `DISPATCHED`（执行中）→ `IN_REVIEW`（已交卷）→ `IDLE`（ACCEPTED 归档）或再 `DISPATCHED`（返工）；`BLOCKED` 须写清阻塞。
- 同时只认**一张** ACTIVE 主单；整模块同步用多张顺号 TASK 切片排队，由主控按 S0–S7 门禁派发，禁止执行侧并行自开多单互殴。
- 可选：大型需求可从外部工单目录桥接，但落到本仓时仍应写入 TASK 并经 ACTIVE 派发，执行侧不旁路。
- **并行 / 多 worktree：** 见 `references/G-parallel-worktree.md`。ACTIVE `note` 须列齐子 TASK + worktree 路径；白名单文件交集必须为空；merge 后才 DEVICE。

---
