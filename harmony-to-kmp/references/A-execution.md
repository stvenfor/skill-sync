## A. 执行总则（CODE / 返工必遵）

> 角色名可随工程约定替换：**主控**（拆 TASK、写 REVIEW、验收）↔ **执行**（读 TASK、白名单内写码、自测、写 RESULT）。用仓库联动总线 `ACTIVE.md` 当信号灯。

### A.0 联动入口（每次会话先做）

路径约定（相对 **KMP 仓根**）：`.agent-bridge/tasks/ACTIVE.md`；TASK / RESULT / REVIEW 同在 `.agent-bridge/` 下（或工程等价桥目录）。

1. 确认本总则已加载。
2. 读 `ACTIVE.md` YAML：
   - **`DISPATCHED`** → 立即读 `task_path` 全量执行。
   - **`IN_REVIEW`** → 已交卷；仅主控改回 `DISPATCHED` 时再动码。
   - **`IDLE`** → 无派单；不擅自大改。
   - **`BLOCKED`** → 读 `note`，说明阻塞点。
3. 交卷后：写完 RESULT，**仅**把 ACTIVE `status` 改为 **`IN_REVIEW`**。

### A.1 角色边界

| 执行做 | 执行不做 |
|------|--------|
| 读 TASK → 白名单写码 → 自测 → 写 RESULT | 扩 scope、擅自改产品/视觉期望 |
| 遵守 AGENTS.md / CLAUDE.md / TASK 列出的 rules | 越界改其它 feature、登录/归因等（除非白名单） |
| 需求不清时 RESULT 标 `BLOCKED` | 猜产品意图、静默大重构、无 EXIT 的大爆炸迁移 |

### A.1.1 禁瞎猜 / 禁默认实现（详见 §I）

- 证据不足 → 只能 `BLOCKED` + 停问。
- 缺 `NO_GUESS` / `NO_DEFAULT` / `EVIDENCE_*` / 相关 `SOURCE_SET` → **REJECTED**。

### A.2 Codegraph 检索（强制优先）

- 找定义、调用链、改前影响面、落点：**必须先 codegraph**；禁止一上来全仓 `grep` / 批量 `Read`。
- 一次问清符号与 blast radius → **只 Read 命中路径** → 仍不够再对 **≤3 路径** 窄 `rg`。
- 例外须写入 RESULT：工具未索引 / 不可用。
- 交卷强制 **CODEGRAPH**：`<查询摘要> → 命中 / 未索引 / 空`。
- 鸿蒙原生只读勘察可用窄 `rg`；Android/iOS 仅旁证；**KMP 改码前影响面仍必须先 codegraph**。

### A.3 Ponytail 写码（强制优先）

- 最小 diff；能删不加；**优先复用**现有 helper / Compose 组件 / 请求与鉴权；不顺手重构；不加未要求的抽象。
- 修 bug / 修编译：先 codegraph 查调用方；能业务侧局部修则局部修。
- **Kotlin/Compose**：跟仓内既有风格与 CPF 支持面；新增 expect 须进清单。
- 单次改动 **>3 文件** → RESULT 一句话说明为何不能更小。
- 跨端转码：映射/状态机，不是字面翻译；禁止镜像搬目录。
- 交卷 **PONYTAIL：** 一行。

### A.3.1 公共 / 共享模块（硬门）

- **默认禁止**修改：shared design-system、跨 feature 公共 Compose、core network/鉴权、全局主题/导航基座、全局工具与基类（边界以仓内 AGENTS.md / PROJECT_MAP 为准）。
- **优先**在业务 feature / 模块内组合调用。
- **仅当** TASK/对照表白名单显式写出公共路径时才可改，且须：
  1. 无回归：codegraph 列调用方 + 最小验证；
  2. 能局部解决就不改公共；
  3. 交卷强制 **PUBLIC_IMPACT**（路径/符号/调用方/为何必须/功能与 UI 影响/验证）。
- 未白名单改公共或无 PUBLIC_IMPACT → **REJECTED**。

### A.4 Git 与敏感目录

- **默认禁止** `git commit` / `git push`。
- **禁止 add**：`.codegenie/`、`.codegraph/`、`build/`、`node_modules/`、`oh_modules/`、`harmonyApp/build/`、证书密钥、**桌面截图目录**等。
- 仅当 TASK 白名单允许时可对源码 `git add`（仍不 commit，除非写明）。
- 对照 Android/iOS/ArkTS **只读**；改码只在目标 KMP 仓（含其 `harmonyApp` 白名单文件）。

### A.5 单次 TASK 流程

1. 从 ACTIVE 解析 `task_path`，只做该 TASK。
2. 实现前 Read AGENTS.md / CLAUDE.md 及 TASK 列出的 rules；CODE 前 Read §I + §E（+§K/§L 若相关）。
3. 复制 RESULT 模板 → `RESULT-<NNN>.md`。
4. 按 VC 自测；RESULT 贴命令与关键输出（含 `./gradlew` 相关任务摘要若适用）。
5. RESULT 状态：`NEEDS_REVIEW` / `BLOCKED` / `DONE_WITH_CONCERNS`。
6. ACTIVE → `IN_REVIEW`。

跨端模块同步：一单一个**切片**（壳 / 主路径 / 分支 / 视觉 triage / interop 岛）；视觉切片须先有 §B 表。

### A.6 聊天交卷格式

```text
STATUS: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT

TASK: TASK-<NNN>
RESULT: .agent-bridge/tasks/RESULT-<NNN>.md

VERIFY: <命令摘要>

CODEGRAPH: <查询摘要> → 命中 / 未索引 / 空
PONYTAIL: <复用了哪些封装 / 为何必须新写>
SOURCE_SET: <本单触及的 source set>
EXPECT_ACTUAL: none | <列表>
CPF_VERSION: <follow-notes|钉扎>
PUBLIC_IMPACT: 无 | 有 → 见 RESULT 专段
NO_GUESS: yes
NO_DEFAULT: yes
EVIDENCE_LOGIC: …
EVIDENCE_UI: …   # 若相关

FILES: （若有）路径 — 一行说明
```

不要宣布「已验收」。DEVICE 结论写在 RESULT/REVIEW。对照实现须附 **§B 同表回勾**。

### A.7 工程索引（按需）

典型 KMP+CPF 仓（随仓调整）：

| 用途 | 位置 |
|------|------|
| 模块与约定 | `AGENTS.md`、`PROJECT_MAP.md` |
| 版本目录 | `gradle/libs.versions.toml` |
| 共享模块 | `composeApp/` 或 `shared/` → `src/commonMain` / `ohosMain` |
| 鸿蒙壳 | `harmonyApp/`（`build-profile.json5`、签名、HAP） |
| Compose 资源 | `commonMain/composeResources` |
| 联动总线 | `.agent-bridge/tasks/ACTIVE.md` |

### A.8 首次接入确认语

**已理解：总则长期有效；每次先读 ACTIVE；检索强制 codegraph，写码强制 Ponytail；默认禁改公共/共享层须 PUBLIC_IMPACT；对照点先只读出表；禁瞎猜/禁默认实现（§I）；Compose first + source-set 纪律；并行时一切片一 worktree，合后烟测；DEVICE 默认等明确授权；存量 ArkTS 走 §L 渐进。**

### A.9 任务队列

- 权威队列以 ACTIVE 为准；勿扫仓自选 TASK。
- 状态机：`IDLE` → `DISPATCHED` → `IN_REVIEW` → `IDLE` 或再 `DISPATCHED`；`BLOCKED` 写清阻塞。
- 同时只认一张 ACTIVE 主单；并行时 note 列齐子 TASK + worktree（§G）。
