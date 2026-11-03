---
name: harmony-to-kmp
description: >-
  在把整模块从 Android/iOS（及可选存量 ArkTS）同步到 KMP/CMP 鸿蒙目标（CPF-KMP-CMP /
  commonMain+ohosMain+harmonyApp）时使用：真机截图落 Mac 桌面、对照源码落 Kotlin/Compose、
  指定模块五轨、source-set/expect-actual 纪律、渐进 akinterop 迁移；规则与脚本在
  references/ scripts/ templates/。
---
# harmony-to-kmp

把**一整模块**落到 **Kotlin Multiplatform + Compose Multiplatform（OHOS via CPF-KMP-CMP）** 时按本 skill 执行。  
视觉/逻辑真值仍来自 Android/iOS（可选对照存量 ArkTS）；**实现语言与落点是 KMP/CMP，不是纯 ArkTS 重写。**  
规范按层存放，按需 Read，**禁止一次灌入全文**。

外部工具链权威：https://gitcode.com/CPF-KMP-CMP/docs （快速开始 / 工具链 / 版本说明 / FFI·CAPI / FAQ / 示例）。本 skill 管**流程与编码硬门**；版本号与插件安装细节以 CPF release notes 为准。

## 何时用

- Android / iOS（及可选存量 Harmony ArkTS）→ **KMP/CMP 鸿蒙目标**整模块对齐
- 工程已是或将接入 CPF 布局：`commonMain` / `ohosMain` / `harmonyApp`（DevEco 签名推包）
- 需要自动截图（`SHOT_PLATFORM=android|ios`）作视觉真值；截图落 **Mac 桌面**、**不进 git**
- 对照源码转 **Kotlin 状态机 + Compose UI**；禁瞎猜、禁默认实现（§I）
- 整模块要提速：默认 **SPEED=fast**（§H）；SHOT‖SURVEY；瘦表先 CODE；**DEVICE 默认等用户明确「开 DEVICE」**（除非 TASK 写死可开）

## 何时不用

- 单点小修、纯文案、与对照端无关的重构
- 明确只要纯 ArkTS/ArkUI 落点（用既有 transform-harmony，勿混用本 skill）
- 无 Android/iOS 可跑页且无逻辑源（先补资产）
- 只要方案讨论、明确不截图/不改码
- 未选定 CPF 版本族、无 harmonyApp 签名能力却强行 DEVICE

## 目录分层（本 skill）

```text
SKILL.md                 # 本文件：编排与硬门摘要
references/
  00-overview.md         # 齐套 / 真值 / 阶段门禁
  A-execution.md         # 角色 / codegraph / Ponytail / 公共层 / Git / RESULT / 队列
  B-mapping-table.md     # 对照点表（Compose 节点 vs View/ArkUI）
  C-shots.md             # 截图轨 android|ios + 桌面落盘 + H5 禁截
  D-logic-source.md      # 逻辑源 → Kotlin 分支表 / 状态机
  E-kmp-cmp-norms.md     # source-set / expect-actual / Compose / ohosMain / Must-fix
  F-module-sync-tracks.md# 指定模块五轨
  G-parallel-worktree.md # 并行勘察 / 多 worktree（Kotlin 模块）
  H-speed.md             # SPEED=fast 默认
  I-no-guess-no-default.md
  J-exit-reroute.md      # R3 退出门与换路
  K-cpf-toolchain.md     # 环境 / 插件 / harmonyApp / 版本钉扎 / 文档链
  L-interop-migration.md # ArkTS 存量 → akinterop → Kotlin 切片
  README.md
scripts/                 # 截图/对拍（自 transform-harmony 适配；verify_ohos.sh 别名）
templates/               # brief / 对照表 / 资源 / 交互 / expect-actual / source-set / 交卷
```

相对路径均相对 **本 skill 目录**。跑脚本在本机 Mac：`bash <skill>/scripts/capture.sh …` 或 `ios_capture.sh …`；OHOS 对拍优先 `verify_ohos.sh`（等价 `verify_harmony.sh`）。

## 存放位置（硬）

- **唯一权威目录（本机）**：`~/.agents/skills/harmony-to-kmp/`
- **禁止**把本 skill 的脚本/规范/模板/说明拷进业务仓
- 业务仓只保留产品/模块本身的 shots-manifest 业务条目（若需要）；Runner 引用 skill 内 `scripts/`
- 截图产物只落选定平台桌面根：`~/Desktop/android-shots/<module>/` 或 `~/Desktop/ios-shots/<module>/`，不进 git、不进 skill 仓
- **保留**既有 `~/.agents/skills/transform-harmony/`；两 skill 并存，按落点选型，勿互相覆盖

## 一句话结论

- **看见什么** → 选定平台自动截图（`SHOT_PLATFORM=android|ios`）
- **怎么算** → 逻辑源源码（状态机 / API / 回写）；**无证据不猜、无表不写默认实现（§I）**
- **怎么写** → **commonMain 能共享则共享**；平台 I/O → `ohosMain`（或 android/ios）；UI **Compose first**；**禁 Android 类型漏进 commonMain**；检索强制 codegraph、写码强制 Ponytail；**默认禁改共享设计系统/公共网络层（须 PUBLIC_IMPACT）**
- **怎么迁** → 存量 ArkTS 用 **akinterop 桥**渐进切片进 Kotlin（§L）；禁止无 EXIT/范围卡的大爆炸重写
- **怎么并行** → 默认 FAST：SHOT‖SURVEY；改码互斥才 multi-worktree；合后烟测；**DEVICE 默认不开，等「开 DEVICE」**

## 指定模块怎么跑（五轨，必须全做）

用户指定模块后，先 Read `references/H-speed.md`（默认 **SPEED=fast**），再 Read `references/F-module-sync-tracks.md`，按序：

1. **截图** → §C（已有复用）
2. **业务逻辑** → §D 分支表 → Kotlin（优先 commonMain）接通 API/状态/回写
3. **UI 效果** → §B 对照点 + §E Compose → DEVICE ≤1%（仅获准后）
4. **资源** → `templates/resource-inventory.md` → composeResources / 平台资源入仓再引用
5. **交互效果** → `templates/interaction-matrix.md` + §B.4；`interact.sh` / 深链仅用于到达态

同步填：`expect-actual-inventory.md`、`source-set-checklist.md`；若触碰存量 ArkTS → Read §L。  
提速：§H + §G；P0 瘦表先 CODE；切片≥2 才 multi-worktree。

## 编排顺序（必须按序）

1. Read `references/H-speed.md`（默认 FAST）+ `references/00-overview.md` → 齐套；缺资产停；**禁止灌读全文**。环境未齐时 Read **§K**。
2–3. **FAST 同开：** 截图轨 Read §C（P0、复用、深链优先）‖ 逻辑/资源/交互只读勘察（§D/§F）；需要时 `ios_index.sh`。
4. 对照点：**先 P0 瘦表**定稿（§B）；有「系统替代/待定/缺失」→ **停问**。【串行】P1 可随后补。同步勾 source-set / expect-actual 清单。
5. CODE 前：Read `references/I-no-guess-no-default.md` + `A-execution.md` + `E-kmp-cmp-norms.md` + **`G-parallel-worktree.md`**；存量 ArkTS → **§L**；版本钉扎 → **§K**；ACTIVE 联动；**检索强制 codegraph、写码强制 Ponytail**；**默认禁改公共/共享层（A.3.1）**；互斥切片 → 多 worktree；只改表内文件。
6. **merge** 后：先 **harmonyApp 烟测**主路径 1–2 态；**仅当用户/TASK 明确「开 DEVICE」** 再 `verify_ohos` ≤1%；交卷短 RESULT；同主题多轮未过按 **§J**（R2 triage，R3 EXIT/换路）。

## 硬门速记

| 门 | 要求 |
|---|---|
| 截图落盘 | `SHOT_PLATFORM=android|ios`（默认 android）；桌面根分端；一轮只认一端；**已有优先复用**；oxipng 默认 **-o 2**；**不做 git 管理** |
| H5 | WebView/H5/内嵌网页 **忽略、禁止截图** |
| source-set | 业务+可共享 UI → `commonMain`；OHOS 仅有能力 → `ohosMain`；**禁 Android/iOS 类型进 commonMain**（`SOURCE_SET`） |
| expect/actual | **仅真平台边界**；能用接口+DI 放 common 则不用 expect；清单见 templates（`EXPECT_ACTUAL`） |
| Compose first | 新 OHOS UI 用 CMP；勿默认重写为 ArkTS；产品强制 ArkTS 岛 → 标 DEFERRED/interop（§L） |
| CPF 版本 | 跟随 CPF release notes；已知主线 **KMP 2.2.21-x / CMP 1.9.2-x**（写 RESULT 时再核对）（`CPF_VERSION`） |
| API 面 | 优先 CPF 已支持 CMP 组件与已发布 Maven；三方须有 OHOS target 实证（示例仓/文档） |
| 鸿蒙对拍 | `verify_ohos.sh` / `verify_harmony.sh`；像素差默认 **≤1%**；只改表内 KMP/CMP 文件；**禁改 Android/iOS 真值凑绿**；**仅 merge + 获准 DEVICE 后** |
| 字重 | 真值看截图/源 textStyle；源端非粗 → Compose **禁擅自 FontWeight.Bold/Medium** |
| 并行 | 勘察可并行；CODE 白名单无交集；一切片一 worktree |
| 检索 | **强制先 codegraph**；禁先全仓 grep |
| 写码 | **强制 Ponytail**；>3 文件须说明 |
| 公共层 | **默认禁改** shared design-system / core network / 跨 feature 公共模块；白名单 + **PUBLIC_IMPACT** |
| 提速 | 默认 **SPEED=fast**；禁无故重截/灌全文/未合并全量对拍 |
| 禁瞎猜/禁默认实现 | **§I** 硬保证；RESULT 必含 `NO_GUESS`/`NO_DEFAULT`/`EVIDENCE_*` |
| 退出/换路 | **§J**：R2 triage；**R3 → EXIT**；换路 A–F；禁同思路 R4 |
| DEVICE | **默认等待明确「开 DEVICE」**；未获准则只交烟测/编译证据 |

## Done

- 指定模块五轨齐：截图 P0、逻辑分支接通（Kotlin）、UI≤1%（若已开 DEVICE）、资源入仓（composeResources）、交互矩阵验收
- 对照表回勾；`SOURCE_SET` / `EXPECT_ACTUAL` / `CPF_VERSION` 交卷字段齐
- 交卷含 **CODEGRAPH** + **PONYTAIL** + **NO_GUESS** + **NO_DEFAULT** + **EVIDENCE_***；改公共层须 **PUBLIC_IMPACT**；并行则 MERGE 报告齐
- 存量 ArkTS 未整仓推倒：桥接边界写进 §L 清单或 DEFERRED

详细条文只在 `references/`；本文件不重复展开。
