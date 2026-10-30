# G. 并行与多 worktree（提速，统一合并）

> 目标：缩短整模块墙钟时间。**只读勘察可并行；改码用多 worktree + 文件白名单互斥；合并后再 DEVICE。** 禁止多 agent 同仓同分支抢写。

## G.0 何时启用

| 场景 | 建议 |
|---|---|
| 整模块五轨、切片 ≥2 且文件白名单可拆开 | **启用**并行 |
| 单切片、文件高度耦合、或对照表未确认 | **不**并行改码 |
| 真机/模拟器稀缺 | 截图与 DEVICE **串行**占设备；勘察仍可并行 |

主控在 `module-brief` / ACTIVE `note` 写：`parallel: yes | no` 与 `worktrees: N`（建议 2–3，软顶 4）。

## G.1 可并行 vs 必须串行

```text
【可并行 · 只读】轨2 逻辑勘察 | 轨4 资源盘点 | 轨5 交互矩阵
         （前提：轨1 截图索引已齐或已声明复用）

【串行 · 单人】§B 对照点表定稿（吃进并行勘察产出）→ S3/S4 切片与白名单

【可并行 · 改码】互斥白名单的 CODE 切片（各占一个 git worktree）
         依赖序建议：逻辑接通 → 资源入仓 → UI 块 → 交互/动效
         无文件交集且无 API/VM 依赖时可同批并行

【串行 · 收口】merge 各 worktree → 主分支编包 → DEVICE verify_harmony（≤1%）
```

硬禁：

- 两个 agent 写**同一文件**或未声明的共享层（请求封装、路由表、公共组件）
- 未合完就对拍 / 多 agent 同抢一台真机编包安装
- 用 cloud agent 改本机仓（本 skill 默认**本机仓库**；用户另说除外）

## G.2 Agent 怎么排（给主控 / 秘书 / 用户）

推荐编制（名字可换成现有 bot）：

| 席位 | 人数 | 职责 | 读哪些层 |
|---|---|---|---|
| **主控**（PM / code review） | 1 | brief、对照表定稿、切白名单、派 ACTIVE、定 merge 序、DEVICE 验收 | 00 / B / F / **G** / E |
| **勘察 agent** | 1–3 并行 | 只读：逻辑分支表 / 资源 inventory / 交互矩阵；不改鸿蒙业务码 | D / C索引 / F；产出进 TASK 附件 |
| **CODE agent** | 1–N（= worktree 数） | 各 worktree 内按 TASK 白名单改码；Codegraph + Ponytail；交 RESULT | A / E / 本切片对照表行 |
| **DEVICE** | 1（合并后） | `verify_harmony` + 用例；超 1% 只改表内鸿蒙文件再验 | C§对拍 / E |

流水线 bot 落位（毛前现网）：

1. **秘书**拆提示词并派单；**PM** 出 brief + 对照表 + 切片白名单。
2. 勘察并行 → 可派多个只读会话（或同一 develop 开多窗只读），产出交回 PM。
3. CODE：每个切片一个 **code develop**（或本机 Cursor 一窗）绑定一个 worktree；ACTIVE 同时只亮**一张主单**时，用「主单 + 子切片 TASK」或顺序把 ACTIVE 指到当前合入目标——**并行 CODE 时主控在 note 列出全部子 TASK 与 worktree 路径**，执行侧认自己的白名单，不扫仓自开单。
4. 全部 CODE 交卷 → **主控 merge** → 再派 DEVICE（一人）。

向用户一句话模板（派单时贴出）：

```text
本轮并行：勘察×{A}（只读）+ CODE×{N} worktree；合并后 DEVICE×1。
Worktree：../Dubbing-wt-<slice> ← TASK-xxx 白名单互斥。
合并序：逻辑 → 资源 → UI → 交互；冲突停问主控。
```

## G.2.1 角色是「帽子」不是固定人设

**不要**写死「Agent A 永远截图、Agent B 永远写码」。每个 bot / Cursor 窗按**当次 TASK 认领的帽子**干活；下一轮可换帽。

| 帽子 | 当次只做什么 | 共同约束 |
|---|---|---|
| **SHOT** | 跑 capture / interact / 补缺态；写出后走无损压缩；更新该模块 index | 产物**只**进 `~/Desktop/android-shots/<module>/`；已有非空 PNG 默认复用 |
| **SURVEY** | 只读逻辑/资源/交互表 | 不改鸿蒙业务码；不挪截图目录 |
| **CODE** | 白名单内改鸿蒙；Codegraph + Ponytail；字重跟 Android | 认自己的 worktree；不重截除非 FORCE 或 TASK 写明 |
| **MERGE** | 合切片分支 | 一人 |
| **DEVICE** | verify_harmony ≤1% | merge 后；占设备时与 SHOT 错开 |

派单写法（贴进 ACTIVE `note` / 秘书提示词）：

```text
模块: <module>
截图根: ~/Desktop/android-shots/<module>/   # 全员只认这一处，禁止拷进仓
本轮认领:
  - @窗1 帽子=SHOT  范围=缺态 P0-3；设备=<serial>
  - @窗2 帽子=CODE  切片=ui-header  worktree=../Dubbing-wt-ui-header  TASK=…
  - @窗3 帽子=CODE  切片=logic-api  worktree=../Dubbing-wt-logic  TASK=…
下一轮可换帽；未点名的帽子本轮不做。
```

桌面截图统一管理：

1. **唯一权威根**：`~/Desktop/android-shots/<module>/`（全 agent 读同一路径；禁每人私建副本目录）。
2. SHOT 写、CODE/DEVICE **只读引用**文件名；CODE 不把 PNG add 进 git。
3. 两 agent 都要动真机时：**串行约设备**（SHOT 时段 / DEVICE 时段），或分 `ANDROID_SERIAL`。
4. 换人接着截：先看 index 与已有 PNG，缺啥补啥，禁止无故整目录重截。

灵活示例：上午窗 A=SHOT、窗 B=CODE；下午窗 A 改戴 CODE（另一切片）、窗 B 戴 DEVICE——合法，只要当次 note 写清帽子与白名单。

## G.3 本机 multi-worktree 规程（鸿蒙仓）

在**鸿蒙仓根**（本机，非 box）执行；路径示例可换：

```bash
# 主分支保持日常开发分支（如 check-8.6.10-dev）
git fetch  # 仅当 TASK 允许；默认可不 fetch
git worktree add -b sync/<module>/<slice> ../Dubbing-wt-<slice> HEAD
# 每个 CODE agent：cd ../Dubbing-wt-<slice>，只改 TASK 白名单文件
```

约定：

| 项 | 要求 |
|---|---|
| 分支名 | `sync/<module>/<slice>`，slice = shell / logic / res / ui-<block> / ix |
| 目录 | 与主仓并列 `../Dubbing-wt-<slice>`，勿放进主仓目录内 |
| 白名单 | TASK 写死绝对/仓内相对路径；**交集必须为空**（共享文件归「基础切片」先合） |
| Git | 各 worktree 内仍默认禁 commit/push；需要落点时按 TASK：可 commit 到切片分支，**禁止**直接 push 主分支 |
| 清理 | merge 并验收后：`git worktree remove ../Dubbing-wt-<slice>`，删已合分支 |

### G.3.1 合并（主控或指定一人）

```text
1. 确认各 RESULT = NEEDS_REVIEW 且 CODEGRAPH 已填
2. 按依赖序：logic → res → ui-* → ix
3. 每次：checkout 主工作分支 → merge --no-ff sync/<module>/<slice>
4. 冲突 → 停；共享层冲突交主控按对照表裁定，禁止各 agent 私自改对方白名单
5. 全合完 → 主 worktree 编包安装 → verify_harmony（一次）
```

合并报告（聊天/RESULT 附）：

```text
MERGE: <slice列表> → <主分支>
CONFLICTS: none | 文件…（已裁定/待问）
DEVICE: pending | ≤1% | 超差回勾中
```

## G.4 切片与白名单怎么拆才并行得起来

优先按**文件互斥**拆，再按依赖分批：

| 批 | 典型切片 | 可并行？ |
|---|---|---|
| 批0 | 共享 API/VM/路由落点（薄） | 单人先合 |
| 批1 | 互不引用的 UI 区块 ets + 各自布局 | 可多 worktree |
| 批2 | 资源 media 入仓（少碰逻辑） | 常可与批1 并行 |
| 批3 | Lottie/手势（依赖 UI 节点已存在） | 批1 合入后再开 |

对照点表「鸿蒙落点」列相同文件 → 必须同一切片或先串行。

## G.5 交卷与队列（相对 A.9 的补充）

- 并行 CODE：**每个 worktree 一份** `RESULT-<NNN>.md`；主控另写一行 `MERGE-PLAN`（序 + worktree 路径）。
- ACTIVE：并行期间 `note` 必须列出全部子 TASK；状态仍用 DISPATCHED / IN_REVIEW；**勿**让执行侧自己 `git worktree add` 扩 scope——worktree 由主控/秘书在派单时建好或写明命令由执行建一次。
- 首次确认语可加半句：`并行时一切片一 worktree，合后再 DEVICE。`

## G.6 Done（本层）

- 勘察并行产出已吃进对照表
- N 个 CODE worktree 白名单无交集、均已交卷
- 按序 merge 无未裁定冲突
- **仅合并后** DEVICE ≤1% + 五轨回勾
