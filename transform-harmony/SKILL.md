---
name: transform-harmony
description: >-
  在把整模块从 Android/iOS 同步到鸿蒙时使用：真机/模拟器自动截图落 Mac 桌面、对照源码转码、指定模块五轨（截图/逻辑/UI/资源/交互）、对照点表与执行总则；可并行勘察与多 worktree 改码再合并；规则与脚本分层在
  references/ scripts/ templates/。
---
# transform-harmony

把**一整模块**同步到鸿蒙时按本 skill 执行。真值三轨写死；**规范按层存放，按需 Read，禁止一次灌入全文**。

## 何时用

- Android / iOS → 鸿蒙整模块对齐
- 需要自动截图（**真机或已装应用的模拟器**）作视觉真值；截图按模块落 **Mac 桌面**、**不进 git**
- 对照源码转码，严格鸿蒙规范；对照点表先只读再改码
- 整模块要提速：并行勘察 + 多 worktree 改码再合并（见 §G）

## 何时不用

- 单点小修、纯文案、与对照端无关的重构
- 无 Android 可跑页且无逻辑源（先补资产）
- 只要方案讨论、明确不截图/不改码

## 目录分层（本 skill）

```text
SKILL.md                 # 本文件：编排与硬门摘要
references/              # 规范规则（按层 Read）
  00-overview.md         # 齐套 / 真值 / 阶段门禁
  A-execution.md         # 角色 / Codegraph / Ponytail / Git / TASK / 交卷 / 队列
  B-mapping-table.md     # 对照点表五列 + Lottie
  C-android-shots.md     # 截图轨 + 桌面落盘
  D-logic-source.md      # 逻辑源勘察
  E-harmony-norms.md     # 鸿蒙落点 / ArkTS / Must-fix / DEVICE
  F-module-sync-tracks.md # 指定模块五轨（截图/逻辑/UI/资源/交互）
  G-parallel-worktree.md # 并行勘察 / 多 worktree 改码 / 合并 / 派 agent
scripts/                 # 可执行脚本（产物不进 git）
  capture.sh interact.sh measure.py run_shots.sh ios_index.sh
  harmony_shot.sh compare_shots.py verify_harmony.sh compress_png.sh
templates/               # manifest / 对照表 / 模块 brief / 资源 / 交互 / 交卷
```

相对路径均相对 **本 skill 目录**。打开某层用 Read；跑脚本在本机 Mac：`bash <skill>/scripts/capture.sh …`。


## 存放位置（硬）

- **唯一权威目录（本机）**：`~/.agents/skills/transform-harmony/`（脚本、规范、模板、文档全在此）
- **Grok Bot 侧**：同一 skill（id `skill-1793292690508`），helpers 与上面对齐
- **禁止**把本 skill 的脚本/规范/模板/说明拷进业务仓（如 `Dubbing/docs/`）
- 业务仓只保留产品/模块本身的 shots-manifest 业务条目（若需要）；Runner 引用 skill 内 `scripts/`
- 截图产物仍只落 `~/Desktop/android-shots/<module>/`，不进 git、不进 skill 仓


## 一句话结论

- **看见什么** → Android 自动截图（桌面 `~/Desktop/android-shots/<module>/`）
- **怎么算** → 逻辑源源码（状态机 / API / 回写）
- **怎么写** → 只跟鸿蒙仓既有架构；**禁系统组件顶替设计稿**
- **怎么并行** → 只读勘察可并行；改码一切片一 worktree（白名单互斥）；**合后再 DEVICE**


## 指定模块怎么跑（五轨，必须全做）

用户指定模块后，Read `references/F-module-sync-tracks.md`，按序：

1. **截图** → §C（已有复用）
2. **业务逻辑** → §D 分支表 → CODE 接通 API/状态/回写
3. **UI 效果** → §B 对照点 + §E → DEVICE ≤1%
4. **资源** → `templates/resource-inventory.md` 入仓再引用
5. **交互效果** → `templates/interaction-matrix.md` + §B.4 Lottie；`interact.sh` / actions 仅用于到达态

提速时另 Read `references/G-parallel-worktree.md`：勘察 2/4/5 可并行；CODE 按互斥白名单多 worktree；merge 后才 DEVICE。

模板：`module-brief.md` / `resource-inventory.md` / `interaction-matrix.md`。五轨勾齐才算该模块转换完成。

## 编排顺序（必须按序）

1. Read `references/00-overview.md` → 齐套与 S0–S7；缺资产停。
2. 截图轨：Read `references/C-android-shots.md`；**已有图优先复用**；缺图再用 `capture.sh` / `run_shots.sh`；需点击滑动用 `interact.sh` 或 manifest `actions[]`。
3. 逻辑/资源/交互勘察：Read §D + §F；**可并行只读**（见 §G）；需要时 `scripts/ios_index.sh <关键词>`。
4. 对照点：Read `references/B-mapping-table.md`；只读源码填 `templates/mapping-table.md`；有「系统替代/待定/缺失」→ **停问**，勿写码。【串行定稿】
5. CODE 前：Read `references/A-execution.md` + `references/E-harmony-norms.md` + **`G-parallel-worktree.md`**；ACTIVE 联动；Codegraph + Ponytail；互斥切片 → 多 worktree；只改表内文件。
6. **merge** 各切片分支到主工作分支（主控一人）；再 DEVICE：`scripts/verify_harmony.sh`（默认 ≤1%）；超差 → 同步优化再验；交卷 `templates/RESULT-handoff.md` + 同表回勾。

## 硬门速记

| 门 | 要求 |
|---|---|
| 截图落盘 | `~/Desktop/android-shots/<module>/`；**已有优先复用**；写出后**自动无损压缩**；**不做 git 管理** |
| 交互抓取 | manifest `actions[]` + `interact.sh`（click/swipe/longpress）；能深链直达优先深链 |
| 鸿蒙对拍 | `verify_harmony.sh`；像素差默认 **≤1%**；超则同步优化（只改表内鸿蒙文件）；**仅 merge 后** |
| 并行 | 勘察可并行；CODE 白名单无交集；一切片一 worktree；禁同分支抢写 |
| 设备 | 真机 **或** 模拟器，均须**已安装**目标应用；多设备 `ANDROID_SERIAL`；DEVICE 不并行抢同一设备 |
| 对照表 | 五列齐；禁「类似弹框」；资源缺失写「缺失，停止」 |
| Lottie | 创建时机 / json / 播完切换 / 循环；禁 Canvas scale；禁 setTimeout 当结束 |
| Git | 默认禁 commit/push；截图产物禁 add；worktree 分支按 TASK 允许再 commit |
| 跳步 | 无对照表 / 无分支表 → 不派 CODE |

## Done

- 指定模块五轨齐：截图 P0、逻辑分支接通、UI≤1%、资源入仓、交互矩阵验收；对照表回勾；交卷含 CODEGRAPH；若并行则 MERGE 报告齐。

详细条文只在 `references/`；本文件不重复展开。
