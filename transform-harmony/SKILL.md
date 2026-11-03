---
name: transform-harmony
description: >-
  在把整模块从 Android/iOS 同步到鸿蒙时使用：真机/模拟器自动截图落 Mac
  桌面、对照源码转码、指定模块五轨（截图/逻辑/UI/资源/交互）、对照点表与执行总则；可并行勘察与多 worktree 改码再合并；规则与脚本分层在
  references/ scripts/ templates/。
---
# transform-harmony

把**一整模块**同步到鸿蒙时按本 skill 执行。真值三轨写死；**规范按层存放，按需 Read，禁止一次灌入全文**。

## 何时用

- Android / iOS → 鸿蒙整模块对齐
- 需要自动截图（**Android 或 iOS 真机/已装应用的模拟器**，由 `SHOT_PLATFORM` 选定）作视觉真值；截图按模块落 **Mac 桌面**、**不进 git**
- 对照源码转码，严格鸿蒙规范；对照点表先只读再改码；**禁瞎猜、禁默认实现（§I）**
- 整模块要提速：默认 **SPEED=fast**（见 §H）；SHOT‖SURVEY；瘦表先 CODE；DEVICE 先烟测

## 何时不用

- 单点小修、纯文案、与对照端无关的重构
- 无 Android 可跑页且无逻辑源（先补资产）
- 只要方案讨论、明确不截图/不改码

## 目录分层（本 skill）

```text
SKILL.md                 # 本文件：编排与硬门摘要
references/              # 规范规则（按层 Read）
  00-overview.md         # 齐套 / 真值 / 阶段门禁
  A-execution.md         # 角色 / Codegraph强制 / Ponytail强制 / 公共层硬门 / Git / TASK / 交卷 / 队列
  B-mapping-table.md     # 对照点表五列 + Lottie
  C-android-shots.md     # 截图轨（android|ios）+ 桌面落盘
  D-logic-source.md      # 逻辑源勘察
  E-harmony-norms.md     # 鸿蒙落点 / ArkTS / Must-fix / DEVICE
  F-module-sync-tracks.md # 指定模块五轨（截图/逻辑/UI/资源/交互）
  G-parallel-worktree.md # 并行勘察 / 多 worktree 改码 / 合并 / 派 agent
  H-speed.md             # 墙钟提速（默认 SPEED=fast）
  I-no-guess-no-default.md # 禁瞎猜 / 禁默认实现（硬拒）
scripts/                 # 可执行脚本（产物不进 git）
  capture.sh ios_capture.sh interact.sh ios_interact.sh measure.py run_shots.sh
  ios_index.sh harmony_shot.sh compare_shots.py verify_harmony.sh compress_png.sh
templates/               # manifest / 对照表 / 模块 brief / 资源 / 交互 / 交卷
```

相对路径均相对 **本 skill 目录**。打开某层用 Read；跑脚本在本机 Mac：`bash <skill>/scripts/capture.sh …` 或 `ios_capture.sh …`（按 `SHOT_PLATFORM`）。


## 存放位置（硬）

- **唯一权威目录（本机）**：`~/.agents/skills/transform-harmony/`（脚本、规范、模板、文档全在此）
- **助手侧 skill 目录**：与本机权威目录 helpers 对齐（改完本机后同步该目录）
- **禁止**把本 skill 的脚本/规范/模板/说明拷进业务仓（如 `Dubbing/docs/`）
- 业务仓只保留产品/模块本身的 shots-manifest 业务条目（若需要）；Runner 引用 skill 内 `scripts/`
- 截图产物只落选定平台桌面根：`~/Desktop/android-shots/<module>/` 或 `~/Desktop/ios-shots/<module>/`，不进 git、不进 skill 仓


## 一句话结论

- **看见什么** → 选定平台自动截图（`SHOT_PLATFORM=android|ios` → `android-shots` 或 `ios-shots`）
- **怎么算** → 逻辑源源码（状态机 / API / 回写）；**无证据不猜、无表不写默认实现（§I）**
- **怎么写** → 只跟鸿蒙仓既有架构；**禁系统组件顶替设计稿**；**检索强制 codegraph、写码强制 Ponytail；默认禁改公共层**
- **怎么并行** → 默认 FAST：SHOT‖SURVEY；改码互斥才 multi-worktree；**合后先烟测再按需满量 DEVICE**；按切片认领帽子（SHOT/CODE/…可换）


## 指定模块怎么跑（五轨，必须全做）

用户指定模块后，先 Read `references/H-speed.md`（默认 **SPEED=fast**），再 Read `references/F-module-sync-tracks.md`，按序：

1. **截图** → §C（已有复用）
2. **业务逻辑** → §D 分支表 → CODE 接通 API/状态/回写
3. **UI 效果** → §B 对照点 + §E → DEVICE ≤1%
4. **资源** → `templates/resource-inventory.md` 入仓再引用
5. **交互效果** → `templates/interaction-matrix.md` + §B.4 Lottie；`interact.sh` / actions 仅用于到达态

提速：默认 Read `references/H-speed.md` + `G-parallel-worktree.md`：**SHOT‖SURVEY**；P0 瘦表先 CODE；切片≥2 才 multi-worktree；merge 后 DEVICE **先烟测**再按需满量 ≤1%。

模板：`module-brief.md` / `resource-inventory.md` / `interaction-matrix.md`。五轨勾齐才算该模块转换完成。

## 编排顺序（必须按序）

1. Read `references/H-speed.md`（默认 FAST）+ `references/00-overview.md` → 齐套；缺资产停；**禁止灌读全文**。
2–3. **FAST 同开：** 截图轨 Read §C（P0、复用、深链优先）‖ 逻辑/资源/交互只读勘察（§D/§F）；需要时 `ios_index.sh`。
4. 对照点：**先 P0 瘦表**定稿（§B）；有「系统替代/待定/缺失」→ **停问**。【串行】P1 可随后补。
5. CODE 前：Read `references/I-no-guess-no-default.md` + `references/A-execution.md` + `references/E-harmony-norms.md` + **`G-parallel-worktree.md`**；ACTIVE 联动；**检索强制 codegraph、写码强制 Ponytail**；**默认禁改公共层（A.3.1）**；互斥切片 → 多 worktree；只改表内文件。
6. **merge** 后 DEVICE：**先烟测主路径 1–2 态**，Must-fix/超差再 `verify_harmony` ≤1%；交卷短 RESULT + 同表回勾。

## 硬门速记

| 门 | 要求 |
|---|---|
| 截图落盘 | `SHOT_PLATFORM=android|ios`（默认 android）；android → `~/Desktop/android-shots/<module>/`，ios → `~/Desktop/ios-shots/<module>/`；一轮只认一端；**已有优先复用**；写出后**oxipng 无损压缩（默认 -o 2，禁流水线 -o max）**；**不做 git 管理** |
| H5 | WebView/H5/内嵌网页 **忽略、禁止截图**；不进 P0 真值与对拍（§C.3.9） |
| 交互抓取 | Android：manifest `actions[]` + `interact.sh`；iOS：深链/人工 + `ios_interact.sh`（stub）；能深链直达优先深链 |
| 鸿蒙对拍 | `verify_harmony.sh`；像素差默认 **≤1%**；超则同步优化（只改表内鸿蒙文件）；**仅 merge 后** |
| 并行 | 勘察可并行；CODE 白名单无交集；一切片一 worktree；禁同分支抢写 |
| 字重 | Android 非粗 → 鸿蒙禁自行 Bold/Medium；真值看截图/源 textStyle（§B.5 / §E.5.3.12） |
| 设备 | 真机端 android|ios；真机 **或** 模拟器均须**已安装**目标应用；Android 多设备 `ANDROID_SERIAL`；iOS 多设备 `IOS_UDID`/`IOS_SERIAL`；DEVICE 不并行抢同一鸿蒙设备 |
| 对照表 | 五列齐；禁「类似弹框」；资源缺失写「缺失，停止」 |
| Lottie | 创建时机 / json / 播完切换 / 循环；禁 Canvas scale；禁 setTimeout 当结束 |
| Git | 默认禁 commit/push；截图产物禁 add；worktree 分支按 TASK 允许再 commit |
| 跳步 | 无对照表 / 无分支表 / 无源码证据 → 不派 CODE；禁止边写边猜、禁止默认实现 |
| 检索 | **强制先 codegraph**；禁先全仓 grep/批量 Read；例外须写 RESULT |
| 写码 | **强制 Ponytail**（最小 diff、复用现成封装）；>3 文件须说明 |
| 公共层 | **默认禁改** `common/` 与跨 feature 公共组件/代码；优先复用；白名单才可改，且 RESULT 必写 **PUBLIC_IMPACT**（功能+UI 影响） |
| 提速 | 默认 **SPEED=fast**：P0 截图、SHOT‖SURVEY、瘦表先 CODE、DEVICE 先烟测；禁无故重截/灌全文/未合并全量对拍 |
| 禁瞎猜/禁默认实现 | **硬保证（§I）**：无分支表源码证据 / 对照点未齐 → 不派 CODE；禁 stub、系统顶替、假数据交差；RESULT 必含 `NO_GUESS`/`NO_DEFAULT`/`EVIDENCE_*` 否则 REJECTED |

## Done

- 指定模块五轨齐：截图 P0、逻辑分支接通、UI≤1%、资源入仓、交互矩阵验收；对照表回勾；交卷含 **CODEGRAPH** + **PONYTAIL** + **NO_GUESS** + **NO_DEFAULT** + **EVIDENCE_***；若改公共层须含 **PUBLIC_IMPACT**；若并行则 MERGE 报告齐。

详细条文只在 `references/`；本文件不重复展开。
