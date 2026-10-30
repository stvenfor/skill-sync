---
name: transform-harmony
description: >-
  在把整模块从 Android/iOS 同步到鸿蒙时使用：真机/模拟器自动截图落 Mac 桌面、对照源码转码、对照点表与执行总则；规则与脚本分层在
  references/ scripts/ templates/。
---
# transform-harmony

把**一整模块**同步到鸿蒙时按本 skill 执行。真值三轨写死；**规范按层存放，按需 Read，禁止一次灌入全文**。

## 何时用

- Android / iOS → 鸿蒙整模块对齐
- 需要自动截图（**真机或已装应用的模拟器**）作视觉真值；截图按模块落 **Mac 桌面**、**不进 git**
- 对照源码转码，严格鸿蒙规范；对照点表先只读再改码

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
scripts/                 # 可执行脚本（产物不进 git）
  capture.sh interact.sh measure.py run_shots.sh ios_index.sh
  harmony_shot.sh compare_shots.py verify_harmony.sh
templates/               # 清单 / 对照表 / 交卷 / ACTIVE 示例
```

相对路径均相对 **本 skill 目录**。打开某层用 Read；跑脚本在本机 Mac：`bash <skill>/scripts/capture.sh …`。

## 一句话结论

- **看见什么** → Android 自动截图（桌面 `~/Desktop/android-shots/<module>/`）
- **怎么算** → 逻辑源源码（状态机 / API / 回写）
- **怎么写** → 只跟鸿蒙仓既有架构；**禁系统组件顶替设计稿**

## 编排顺序（必须按序）

1. Read `references/00-overview.md` → 齐套与 S0–S7；缺资产停。
2. 截图轨：Read `references/C-android-shots.md`；**已有图优先复用**；缺图再用 `capture.sh` / `run_shots.sh`；需点击滑动用 `interact.sh` 或 manifest `actions[]`。
3. 逻辑轨：Read `references/D-logic-source.md`；需要时 `scripts/ios_index.sh <关键词>`。
4. 对照点：Read `references/B-mapping-table.md`；只读源码填 `templates/mapping-table.md`；有「系统替代/待定/缺失」→ **停问**，勿写码。
5. CODE 前：Read `references/A-execution.md` + `references/E-harmony-norms.md`；ACTIVE 联动；Codegraph + Ponytail；只改表内文件。
6. DEVICE：`scripts/verify_harmony.sh` 鸿蒙真机同态对拍（默认 ≤1%）；超差 → 同步优化再验；交卷 `templates/RESULT-handoff.md` + 同表回勾。

## 硬门速记

| 门 | 要求 |
|---|---|
| 截图落盘 | `~/Desktop/android-shots/<module>/`；**已有优先复用**（`FORCE_RECAPTURE=1` 才重截）；**不做 git 管理** |
| 交互抓取 | manifest `actions[]` + `interact.sh`（click/swipe/longpress）；能深链直达优先深链 |
| 鸿蒙对拍 | `verify_harmony.sh`；像素差默认 **≤1%**；超则同步优化（只改表内鸿蒙文件） |
| 设备 | 真机 **或** 模拟器，均须**已安装**目标应用；多设备 `ANDROID_SERIAL` |
| 对照表 | 五列齐；禁「类似弹框」；资源缺失写「缺失，停止」 |
| Lottie | 创建时机 / json / 播完切换 / 循环；禁 Canvas scale；禁 setTimeout 当结束 |
| Git | 默认禁 commit/push；截图产物禁 add |
| 跳步 | 无对照表 / 无分支表 → 不派 CODE |

## Done

- 主路径可走通；P0 截图有 DEVICE 结论；对照表回勾；Must-fix / 禁区无破窗；交卷含 CODEGRAPH。

详细条文只在 `references/`；本文件不重复展开。
