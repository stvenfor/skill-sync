# 跨端模块同步鸿蒙

把**一整模块**同步到鸿蒙时按本 skill 执行。真值三轨写死，缺一停手。CODE 阶段另遵**执行总则**（角色边界、Codegraph、Ponytail、Git、单次 TASK、交卷格式）。对照实现另遵**对照点表**（先只读、五列硬门、禁系统替代、Lottie 细则）。

## 何时用

- 要从 Android / iOS 对齐一整块产品能力到鸿蒙
- 需要**自动截图**当视觉真值（真机或已装应用的模拟器），再对照源码落鸿蒙实现；截图按模块落 Mac 桌面、不进 git
- 需要长列表、多态页、复杂交互的可索引截图包
- 需要按鸿蒙既有架构与开发规范「转码/移植」，而不是镜像搬目录
- 执行侧按 TASK/ACTIVE 联动写码、交卷、验收返工
- 需要按界面对应点表先只读勘察再改码，禁止系统组件顶替设计稿

## 何时不用

- 单点小修、纯文案、与对照端无关的鸿蒙内部重构
- 只有设计稿、没有可跑的 Android 页也没有 iOS 逻辑（先补资产再开本流程）
- 用户只要方案讨论、明确不要截图或不要改码

## 一句话结论

- **看见什么** → Android 自动截图集（按屏、按态）
- **怎么算/怎么走** → iOS（或约定的逻辑源端）源码：状态机、接口、边界、回写
- **代码怎么放、怎么写** → **只跟目标鸿蒙仓既有分层、路由、组件、命名与门禁**；禁止按 Android Activity / iOS Pod 目录镜像
- **对照原项目实现，不要用鸿蒙系统组件替换设计稿**

三边冲突一律停问产品，禁止「鸿蒙先凑合」倒推期望。

---

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

**文件所有权：** `TASK` / `REVIEW` 由主控维护；`RESULT` 由执行维护。勿改 TASK 核心需求（可选把 TASK 状态标 `IN_PROGRESS`）。

跨端同步流水线中的粗分：

| 角色 | 负责 |
|------|------|
| 主控 / PM / code review | 范围、CLARIFY、映射表、PROMPT、STAGE_A、DEVICE 验收、REVIEW |
| 执行 / code develop | CODE、自测 VC、RESULT、按 REVIEW 返工 |
| 截图轨 | Android shots-manifest 跑通与索引（可主控派或专用脚本） |

### A.2 Codegraph 检索（必须）

- **理解调用链、找定义、改前看影响面（blast radius）** → 优先 MCP **`codegraph_explore`**（自然语言或符号/路径）。
- **禁止**默认先全仓 `grep` + 批量 `Read` 代替 codegraph。
- **例外：** 未索引、工具报未索引、或某文件 codegraph 标 stale → 仅对该文件 `Read` 或**窄范围** `rg`。
- 每次交卷在 **RESULT** 与聊天回报中写 **CODEGRAPH**：`<查询摘要> → 命中 / 未索引 / 空`。
- 对照端（iOS/Android/Flutter）只读勘察可用窄 `rg`/`Read`；**鸿蒙改码前影响面仍优先 codegraph**。

### A.3 Ponytail 写码（必须）

- **最小 diff**；能删不加；复用现有 helper/组件/请求与鉴权方式；不顺手重构相邻代码。
- 不加未要求的抽象、配置、一层 wrapper。
- 修 bug / 修编译：**先 codegraph 查被改符号的全部调用方**，尽量在共享层修一次根因。
- **ArkTS：** 改 `*.ets` 前 Read 仓内 `arkts-no-any-unknown`（或等价）规则。
- 与 Ponytail 冲突时以 **`AGENTS.md` / `CLAUDE.md`** 为准。
- 单次改动 **>3 个文件** → RESULT 用一句话说明「为何不能更小」。
- 跨端转码仍遵守下文「转码原则」：映射/状态机，不是字面翻译；禁止镜像搬目录。

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

**已理解：总则长期有效；每次先读 ACTIVE 联动；检索用 codegraph，写码用 Ponytail；对照点先只读出表，禁系统替代设计稿。**

之后用户说 **「联动」** 或发任意消息时，先执行 **A.0** 再决定是否改代码。

### A.9 任务队列说明

- **权威队列：** 以 **`tasks/ACTIVE.md`** 为准；**勿**扫仓库自选 `TASK-*.md` 开干。
- 主控派发记录见 ACTIVE 的 `task_id` / `task_path` / `note`。
- 状态机：`IDLE` → `DISPATCHED`（执行中）→ `IN_REVIEW`（已交卷）→ `IDLE`（ACCEPTED 归档）或再 `DISPATCHED`（返工）；`BLOCKED` 须写清阻塞。
- 同时只认**一张** ACTIVE 主单；整模块同步用多张顺号 TASK 切片排队，由主控按 S0–S7 门禁派发，禁止执行侧并行自开多单互殴。
- 可选：大型需求可从外部工单目录桥接，但落到本仓时仍应写入 TASK 并经 ACTIVE 派发，执行侧不旁路。

---

## B. 对照点表（先只读、后改码；硬门）

> **对照原项目实现，禁止用鸿蒙系统组件替换设计稿。**  
> CODE 前必须先出表；表未过门不准写码。做完用**同一张表**逐行对照验收。

### B.1 开工顺序（不可颠倒）

1. **只读源码**（逻辑源 + 鸿蒙落点勘察 + 资源盘点），**不要写代码**。
2. 输出 **对照点表**（下节），每行一个界面对应点。
3. 表里任何一行是「系统替代」「待定」、或资源写「缺失」却未裁定 → **停下来问用户**，不要实现。
4. 用户确认表后，**只改表里写明的文件**（白名单外禁止动）。
5. 做完用同一张表逐行勾选，标出和源不一致的地方（文件名/控件/资源/时序/禁区）。

### B.2 对照点表（每行五列，禁止含糊）

| # | 源文件和控件 | 鸿蒙落点 | 资源 | 时序 | 禁止项 |
|---|---|---|---|---|---|
| 1 | **类名或资源路径**（不要写「类似弹框」「某个列表」） | 复用哪个**现有**组件，或新建哪个**具体文件路径** | 要拷贝的**文件名**；没有则写 **「缺失，停止」** | 谁触发、成功后改哪个状态、**明确不发生什么** | 本点不允许的系统 API（例：`showDialog` / `AlertDialog` / `SymbolGlyph` / 进页自动播放） |

列约束：

1. **源文件和控件**：写清源端类/方法/布局 id/资源路径；禁止「类似 xxx」「参考弹框」等模糊词。
2. **鸿蒙落点**：写死复用组件名或新建文件；禁止「找个差不多的组件」。
3. **资源**：要拷贝的真实文件名；**缺失就写「缺失，停止」**；**禁止**用系统图标、SymbolGlyph、手绘/灰块/网图占位代替。
4. **时序**：触发者 → 成功态改哪个 `@State`/VM 字段 → 失败/取消不发生什么；禁止只写「点了会弹」。
5. **禁止项**：点名本点禁用的系统 API/行为；规格未写「用系统」则产品弹框/图标一律禁系统替代。

**停问条件（任一即停，问用户后再实现）：**

- 任一格为「系统替代」「待定」「TBD」「类似…」
- 资源列为「缺失，停止」且用户未裁定「砍掉该点 / 补资源后再做」
- 鸿蒙落点写不清具体文件或组件名

### B.3 改码与回勾

- 只改表中「鸿蒙落点」列写明的文件（及表内点名的资源拷贝）。
- 交卷时附**同一张表**，增加列或旁注：`对照结果 = 一致 | 不一致（差异一句）`。
- 不一致项不得标整单完成；视觉轨须能指回截图号或源控件。

### B.4 Lottie / 动效专项（表外仍须写清）

每个 Lottie 点在对照表「时序」列或附录写死：

| 项 | 必须写明 |
|---|---|
| 何时创建 | 进页 / 点击 / 成功态 / 其它（禁止含糊） |
| 播哪一个 json | 资源路径或文件名（须已入仓或表内「要拷贝」） |
| 播完切哪一个 | 下一 json / 静止帧 / 卸载体；无则写「播完停在末帧」 |
| 是否循环 | 是/否；循环则写起止意图 |
| 禁止 | **不要对 Canvas 做 scale**；**不要用 `setTimeout` / 盲 sleep 当播放结束**；用播放完成回调或仓内 Lottie 完成事件 |

DEVICE 先验「时机与切换」再验观感；「随便播一个差不多的」破禁停手。

### B.5 与 Must-fix / PROMPT 的衔接

每条视觉/弹框/图标切片的 Must-fix 首段仍用「真值 + 禁区 + 证据」；**对照点表是 STAGE_A 前置产物**，缺表不得派 CODE。PROMPT/TASK 白名单路径必须 ⊆ 表中鸿蒙落点列。

---

## 0. 开工前齐套（缺一项停 CODE）

### 0.1 输入资产

```text
sync/<module>/
  android-shots/     # 指向或镜像桌面 ~/Desktop/android-shots/<module>/；权威在桌面，不进 git
  ios-logic/         # map.md + notes-state-machine.md（或等价）
  harmony-anchor/    # where-to-put.md + patterns.md
  shots-manifest.yaml
  mapping-table.md   # §B 对照点表（确认后）
```

| 资产 | 必须有 |
|---|---|
| Android 截图索引 | 主路径 + 关键态；文件名稳定可检索 |
| 逻辑源映射 | 入口类/方法、API、分支表 |
| 鸿蒙落点 | feature / pages / api / model / 路由；必须复用的组件名单 |
| 对照点表 | §B 五列齐；无系统替代/待定 |
| 完成定义 | 可勾选：主路径、分支、DEVICE 对照、回写 |

### 0.2 向用户确认的最小信息（未知才问，一次 ≤3）

1. 模块名与三端路径（Android 工程、iOS/Pod、鸿蒙 feature）
2. 是否已有深链 / 是否允许 debug-only 截图入口
3. 测试账号与可固定 fixture（课/内容 ID）
4. 本轮优先切片（壳 / 主路径 / 分支）与是否允许改码、commit

未决用「复述 + 二选一带推荐」；产品对错必须问，实现路径可提案默认推进。对照点表中的「系统替代/待定/缺失」优先于其它未决项停问。

---

## 1. 真值优先级

| 维度 | 第一真值 | 第二参考 | 禁止 |
|---|---|---|---|
| 布局 / 区块 / 主按钮 / 空态外观 / 动效观感 | Android 截图集 | 与截图一致的设计稿 | 用鸿蒙现状或「差不多」当期望；**禁系统组件顶替设计稿** |
| 入口参数、状态机、分支、API、回写、权限失败 | 逻辑源端源码 | 接口文档 | 只看 Android UI 猜逻辑 |
| 目录、导航、DI、网络、弹框/图标、播放器/评测复用 | 鸿蒙仓同类已有实现 | 同仓已验收范例 | 镜像 Android/iOS 工程树 |

冲突处理：

1. 截图有、逻辑源无 → 澄清废弃 UI 还是源端缺实现
2. 逻辑有、截图无态 → 补截该态，或标「逻辑有、UI 隐藏」并写验收
3. 鸿蒙组件名 ≠ 截图组件名 → **用鸿蒙仓内/设计组件实现截图观感**，不新建平行体系、不用系统控件凑合（规格写明除外）

---

## 2. 阶段门禁（必须按序；禁止跳步派 CODE）

状态板建议字段：`主单 | CODE | DEVICE | 产物时刻 | 禁混项`

| 阶段 | 产出 | 放行条件 |
|---|---|---|
| S0 范围 | `CLARIFY_<MODULE>_SCOPE.md` | 非目标、完成定义、硬门写死 |
| S1 结构 | `CLARIFY_<MODULE>_STRUCTURE.md` | 映射表 + 双树 + 偏差 + **分支表** |
| S2 截图 | `android-shots/` + index | P0 态齐；清单可 `--module/--page/--state` 过滤 |
| S2b 对照点 | `mapping-table.md`（§B） | 五列齐；无系统替代/待定；资源缺失已裁定 |
| S3 WBS/PROMPT | 可独立派的切片提示词 | 视觉轨含 Must-fix 三段；白名单 ⊆ 对照表 |
| S4 STAGE_A | Must-fix、TC、资源核对 | 缺分支表/资源/对照表 → 不派 B |
| S5 CODE | 仅表内写明文件；遵 **A.+B.** | 本机仓优先；半程可报「改码齐、在编包」 |
| S6 DEVICE | 对照截图 + **同表回勾** | 静态 PASS ≠ 视觉结案；真机前不喊整单完成 |
| S7 回灌 | 坑点对齐相关角色 | 禁止只对功能不对坑点 |

**切片顺序（降低翻车）**：地图（无码）→ 对照点表确认 → 壳+空失败 → 主路径 → 分支 → 视觉收敛 triage → 回写/上下游。整模块禁止一次糊成一单。

---

## 3. Android 自动截图（视觉真值轨）

### 3.1 架构（清单驱动，禁止盲爬）

```text
shots-manifest.yaml
    → Shot Runner（Instrumentation 优先；adb 仅过渡）
    → Mac 桌面按模块目录（权威落盘，不进 git）
         ~/Desktop/android-shots/<module>/
         A-<page>-<state>-<seq>.png
         00-index.md
         run-report.json
```

默认栈：YAML 清单 + Debug/正式深链打开页 + UI Automator/Espresso/Compose Test + 截屏落盘 + 生成索引。

### 3.1.1 设备目标（真机与模拟器）

- 自动化截图脚本**既可截真机上已安装应用，也可截模拟器上已实际安装的应用**（同一套清单与 Runner）。
- 运行前用 `adb devices`（或等价）确认目标在线；多设备时用 `-s <serial>` / manifest `deviceSerial` 钉死一台，禁止盲选。
- 目标上须**已安装**对应包名应用（正式包或可深链的 debug 包）；未安装则停，先装再跑，不改清单凑合。
- 真机与模拟器产出的文件名规则相同；`run-report.json` 记 `deviceSerial`、型号/AVD 名、 density，便于 DEVICE 对照时知悉来源。
- 像素门禁默认固定一种 profile（优先约定模拟器 profile）；换真机分辨率时在 index 注明，不与另一 profile 混比。

### 3.1.2 Mac 桌面落盘与目录（统一管理，不做 git 管理）

- **权威根目录（本机 Mac）：** `~/Desktop/android-shots/`（可用环境变量 `ANDROID_SHOTS_ROOT` 覆盖，默认即桌面该文件夹）。
- **按模块新建子文件夹统一管理：** `~/Desktop/android-shots/<module>/`；模块名与 manifest `modules[].id` 一致（稳定英文短名）。
- 单次 run 可再分子目录 `runs/<timestamp>/`，稳定真值可提升/拷贝到模块根或 `current/`，index 指向选用的那套。
- **不做 git 管理：** 截图 PNG、index、run-report **禁止** `git add` / commit / 放进仓库跟踪目录；勿写入鸿蒙仓、Android 仓的 `artifacts/` 并提交。脚本与 `shots-manifest.yaml` 可留在工程 tools（若入库），产物只落桌面。
- 鸿蒙对照时：CLARIFY / DEVICE / 对照点表引用桌面路径下的**具体文件名**；需要时只读拷贝到对话附件或本机 bridge 的**本地 ignore 区**，仍不进 git。

### 3.2 Manifest 最小字段

- `modules[].id` / `pages[].id` / `shots[].state` 稳定英文短名
- `open`：`deep_link` | `activity` | `compose_route` | debug Shot 入口
- `waitFor`：优先 resource-id / testTag，其次文案
- `actions[]`：click / scroll_* / swipe / sleep / grant_permission / setup
- `capture`：`window`（默认）| `region` | `stitch`（仅附录）
- `file`：`A-<page>-<state>-<seq>.png`
- `settleMs`、可选 `loginOverride`、`note`（给鸿蒙对照一句话）

### 3.3 一页多态（Page × State）

一页 ≠ 一张图。最小单元是 `page + state`。过滤：`--module` / `--page` / `--state`。

### 3.4 长列表

| 级别 | 做法 | 主真值？ |
|---|---|---|
| L1 分段屏 | list-top / list-anchor-id / list-end | **是** |
| L2 Cell 特写 | 滚到 item 后整窗或 region | 该交互是 |
| L3 stitch 长图 | 多帧拼接 | **否**，附录 |
| L4 数据快照 | JSON 字段 | 逻辑验收 |

滚动动作优先级：`scroll_to_index` / 语义定位 → `scroll_until` → 盲 `scroll_by`。fixture 固定条数与顺序；关动画；截前 idle。

### 3.5 复杂交互

交互 = 状态机，不是一条录像。每节点一态一图。

- 中间态优先 **深链/mock 直达**，其次 page 级 `setup`，少用 `dependsOn` 连跑
- 弹层截**整窗含蒙层**；系统权限/分享框标机型差异，默认不进跨端像素门禁
- 音视频/Lottie：写清触发时机与截取帧；随机波形不对像素
- 手势：拖前/拖后两态；残影一般不截

### 3.6 门禁分级

- **P0**：各页 default + 主路径关键态（含主弹层）
- **P1**：list-top/end、empty、error
- **P2**：stitch、region 特写、进行中帧（stitch/随机动效不进像素 diff）

### 3.7 稳定性清单

关窗口动画；`waitFor` 业务控件禁止只盲 sleep；Demo Mode 减状态栏噪点；真机与模拟器均可，固定一种对比 profile；失败留 `FAIL-<state>.png` + UI dump；换账号态要 force-stop 重登。

### 3.8 与鸿蒙衔接

视觉真值以 **Mac 桌面** `~/Desktop/android-shots/<module>/` 的稳定 run 为准（见 §3.1.2），**不进 git**。CLARIFY 映射表与 DEVICE 期望**必须写具体文件名**（可写桌面相对路径），禁止「列表正常」。对照点表「源文件和控件」列应能指回截图号或源类名。若流水线需要本地 `sync/<module>/android-shots/` 镜像，仅作只读拷贝且同样 ignore，不以仓内副本为唯一真值。

---

## 4. 逻辑源端勘察（行为真值轨）

产出 `ios-logic/map.md` + `notes-state-machine.md`（名称可随源端改，内容不可少）：

1. 用户入口 → 路由/参数表
2. 主 VC/Presenter/VM（或等价）与子工厂
3. 网络：路径、字段、空/失败
4. 完成回写与上下游回调
5. 权限与错误路径
6. **派 CODE 前硬门**：`入口 → 状态/分支 → 成功/失败/空态 → 对应截图号`
7. 勘察结果填入 **§B 对照点表**（类名/资源路径级，禁止「类似弹框」）

缺分支表或对照点表 → 停，不准边写边猜。

---

## 5. 鸿蒙锚点与开发规范（落点 + 转码纪律）

### 5.1 架构落点（先找同类）

1. 在目标 feature 内找已有 List/Detail/Exam/Player/Pay 等范式；**只扩页与 API**，不新开「Android 式」包名
2. 模型与 API：与仓内既有 `model/`、`common/api/`（或项目等价目录）同风格；字段注释可写「对齐源端 Xxx」
3. 页面进既有 `pages/`；路由走既有 pagesMap / schemeMap / NavPathStack 习惯
4. 跨模块回调用鸿蒙已有 Nav 结果/回调，**不引入**源端 Delegate 镜像层
5. 弹框、图标、进度、二次确认 → **复用仓内组件 / 设计导出**；**禁止系统 AlertDialog / SymbolGlyph 顶替设计稿**
6. 禁止：为同步复制 Android 布局层级或 iOS 文件名；禁止未经批准的「先能跑再重构」平行实现

### 5.2 转码原则（对照源码 → 鸿蒙，不是字面翻译）

| 做 | 不做 |
|---|---|
| 先写对照点表与映射表再改码 | 按 XML/Storyboard 控件树逐个翻译 |
| 按用户路径与状态机实现 | 按源端文件名一一建鸿蒙文件 |
| UI 块对齐截图锚点与屏占比 | 用系统控件「看起来像」交差 |
| 逻辑对齐源端分支表 | 只看截图猜接口与回写 |
| 复用鸿蒙播放器/评测/列表范式 | 为省事拷贝三方或新建第二套 |

推荐 CODE 顺序：对照点表确认 → 路由与参数 → 壳与导航 → 数据与 API（空/失败先接通） → 主路径 UI 块（按截图区块） → 分支与回写 → 动效与资源。

### 5.3 ArkTS / ArkUI 编写规范（严格执行）

1. **语言**：按项目 ArkTS 子集；避免任意动态特性、隐式 any、与声明式 UI 冲突的写法；新增 API 与仓内现有 ets 风格一致
2. **UI 结构**：Column / Row / Stack / Flex / List 等声明式组合；几何先验先定**贴顶/对齐锚点/屏占比**，再调间距；禁止无真值的「经验尺度配方」来回打
3. **状态**：`@State` / `@Prop` / `@Link` / `@Provide`/`@Consume` 等按数据所有权选用；副作用放生命周期与明确回调，避免在 build 里做请求
4. **列表**：长列表用 List + LazyForEach（或仓内等价）；key 稳定；与截图分段态对应可测
5. **路由参数**：类型明确，深链/页参与逻辑源入参表对齐；禁止魔法字符串散落
6. **异步与错误**：网络失败、空数据、权限拒绝必须有可观察 UI 态，并在分支表与截图有对应
7. **资源**：图片/Lottie/音频**先入仓**再引用；记录路径与校验（如 md5）；缺资源写「缺失，停止」，不准交差
8. **弹框**：默认用设计/仓内自定义弹层；**禁系统 AlertDialog/promptAction.showDialog 当产品弹框**，除非规格写明「用系统」
9. **图标**：设计导出或仓内图标集；**禁 SymbolGlyph / 系统符号图标顶替**，除非规格写明
10. **占位**：禁自画灰色块冒充正式 UI；禁「临时 Image 网图」当终态
11. **动效 / Lottie**：按 **§B.4** 写死创建时机、json、播完切换、循环；**禁对 Canvas 做 scale**；**禁用 setTimeout / 盲 sleep 当播放结束**；DEVICE 先验时机再验观感
12. **命名**：文件/组件/方法跟鸿蒙仓约定，不跟 Android/iOS 文件名；公共组件提取前先 STAGE_A 同意
13. **边界**：本单禁混无关产品线；共壳修改必须声明回归范围；**只改对照表写明的文件**
14. **工程卫生**：不擅自 commit/push；不引入与门禁冲突的依赖；调试入口仅 debug/dev 源集

### 5.4 Must-fix 首段固定模板（视觉/弹框/图标轨缺此三段不得派 CODE；且须先有 §B 对照点表）

1. **真值**：对照 Android 哪张图 / 逻辑源哪段；弹框=设计或仓内组件；图标=导出路径
2. **禁区**：禁系统弹框、禁系统图标、禁自画占位；规格未写「用系统」一律破禁停手
3. **证据**：资源已入仓；路径与校验；缺资源不准交差

视觉轨另遵：UI 关键几何相对截图可验收（项目若有 UI≤2% 等阈值则写入本单硬门）；**静态代码 PASS ≠ 视觉结案**。

### 5.5 PROMPT / TASK 必备块（每条切片）

```text
角色与目标
真值（截图号 + 逻辑源符号/API）
对照点表行号（§B）
鸿蒙落点（目录/页/复用组件 — 须与表一致）
禁区（系统弹框/图标/占位/混轨/未授权 commit/Canvas scale/setTimeout 当结束）
证据（资源路径）
完成定义 / VC1…（可观察、可命令复核优先）
非目标
白名单路径（§只改这些 ⊆ 对照表）
约束（Git / 敏感目录 / 是否可 add）
回报格式（交卷模板 + CODEGRAPH 行 + 同表回勾）
```

---

## 6. DEVICE 与打回

1. 视觉用例表：`用例ID | 截图号 | 操作 | 期望可观察点 | 现状`
2. 逻辑用例表：按分支表，可不截图但必须可复现
3. **对照点表回勾**：逐行 `一致 | 不一致（差异一句）`
4. 同主题多轮打回 → **先合并一张 triage** 再派下一轮 CODE，禁止平行多单互殴
5. 编包半程可报「改码齐、在编包」；**整单完成**仅在 DEVICE 结论后
6. 过门后用「重点 / 做了什么 / 为什么 / 下次避免 / 沉淀一句」回灌相关角色

---

## 7. 质量门禁清单（派单前自勾）

- [ ] 范围与非目标已确认
- [ ] Android 截图索引覆盖主路径 + 关键态（P0）；真机或已装应用的模拟器可跑
- [ ] 截图落 Mac 桌面按模块目录（`~/Desktop/android-shots/<module>/`），不进 git
- [ ] 逻辑分支表齐（入口→成功/失败/空态↔截图号）
- [ ] 鸿蒙落点与复用组件已写死
- [ ] 对照点表五列齐；无「系统替代/待定」；资源无静默系统顶替
- [ ] Lottie 点含创建时机/json/播完切换/循环；禁 Canvas scale、禁 setTimeout 当结束
- [ ] Lottie/动效时机表（若有）
- [ ] Must-fix 含真值+禁区+证据
- [ ] WBS/PROMPT/TASK 可按切片独立派；ACTIVE 队列清晰；白名单 ⊆ 对照表
- [ ] CODE 遵 A.1–A.4（角色/Codegraph/Ponytail/Git）
- [ ] DEVICE 引用具体截图文件名；同表回勾
- [ ] 打回合并 triage；交卷含 CODEGRAPH 行
- [ ] 过门经验回灌

---

## 8. 文档骨架

```text
1. 文首映射（产品块 ↔ 截图号 ↔ 逻辑源 ↔ 鸿蒙落点）
2. 真值树 / 鸿蒙现状树（有/残缺/无 + 证据）
3. 偏差清单（严重度排序）
4. 业务分支表
5. shots-manifest 与截图索引
6. §B 对照点表（确认版）
7. WBS + PROMPT-* / TASK-*
8. Must-fix / TC / 验收计划
9. ACTIVE 队列与 RESULT/REVIEW（含同表回勾）
10. 附录：API、裁定项、stitch 附录图、Lottie 时序
```

---

## 9. 风险默认策略

| 风险 | 策略 |
|---|---|
| 截图不全 | 停 CODE；补态或缩小到已有截图子集 |
| Android 与逻辑源产品不一致 | 单列裁定，期望冻结 |
| 鸿蒙无同类组件 | 先扩展最近范式；新建须 STAGE_A 批 |
| 截图数据漂移 | fixture + dataVersion；真值包人工/脚本挑稳定 run |
| 长列表/复杂交互不稳 | 分段屏+深链中间态；stitch 不进门禁 |
| 单过大 | 按第 2 节切片；禁止只转发笼统指令 |
| 系统弹框/图标顶替 | Must-fix / §B 破禁停手 |
| 跳过 codegraph / 大 diff | RESULT 不合格；主控 REJECTED |
| 未授权 git / 敏感目录 | 破禁停手；从暂存区撤出 |
| 对照点表含糊或系统替代 | 停问用户；禁止实现 |
| Lottie 用 setTimeout/Canvas scale | 破禁；改完成回调与仓内播法 |

---

## 10. 执行检查（对本 skill）

开始前：资产齐套；对照点表已确认或本轮仅出表；执行侧已回首次确认语（若为本会话首次）。
进行中：任何「凭感觉对齐」或「系统凑合」→ 停，回到截图号、源码符号或对照表行；改码前走 codegraph。
结束前：DEVICE 表与对照点表回勾；交卷格式完整；未授权不 commit；经验已回灌（若本轮要求）。

## Done 标准

- 约定切片在鸿蒙上主路径可走通，关键分支与回写对齐逻辑源
- P0 截图均有 DEVICE 对照结论（非仅静态 PASS）
- 实现落在鸿蒙既有架构内，Must-fix / §B 禁区无破窗；无系统组件顶替设计稿
- CODE 符合 Ponytail + Codegraph 交卷；ACTIVE 已 IN_REVIEW 或归档；对照点表逐行回勾
- 产物（CLARIFY / manifest / shots / mapping-table / TASK·PROMPT / RESULT / REVIEW）可交给下一角色续做
