# C. 视觉真值截图轨（Android / iOS）

视觉真值端由 **`SHOT_PLATFORM=android|ios`** 选定（默认 **android**）。同一模块一轮只认一端 PNG；禁止混两端作同一 DEVICE 对比源。

> OHOS/KMP 侧截图与对拍：`harmony_shot.sh`、`verify_ohos.sh`（`verify_harmony.sh` 同实现）。目标 UI 为 **CMP on OHOS**（`harmonyApp` 推包后前台页），不是要求重写为 ArkUI 声明式树再对拍。

## 脚本入口（本 skill）

| 脚本 | 作用 |
|---|---|
| `scripts/capture.sh` | 仅 Android → `~/Desktop/android-shots/<module>/` |
| `scripts/ios_capture.sh` | 仅 iOS → `~/Desktop/ios-shots/<module>/` |
| `scripts/ios_interact.sh` | iOS 到达态说明（stub；优先深链） |
| `scripts/measure.py` | Android uiautomator → dp 表 |
| `scripts/run_shots.sh` | 按 `SHOT_PLATFORM` 选 capture |
| `scripts/ios_index.sh` | iOS 关键词只读索引 |
| `scripts/harmony_shot.sh` | OHOS hdc 截图并排 |
| `scripts/interact.sh` | Android 点击/滑动 |
| `scripts/compare_shots.py` | 真值端 vs OHOS 像素差（默认 1%） |
| `scripts/verify_harmony.sh` / `verify_ohos.sh` | OHOS 同态截图 + 对比 |
| `scripts/compress_png.sh` | PNG 无损压缩（oxipng 默认 **-o 2**） |

模板：`templates/shots-manifest.example.yaml`。产物**不进 git**。已有 PNG **默认复用**。

### C.0 真机端选择

| 项 | 规则 |
|---|---|
| 选择器 | `SHOT_PLATFORM=android|ios`；默认 android |
| 一轮一真值 | 禁止混用两端 PNG |
| Android 根 | `~/Desktop/android-shots/<module>/` |
| iOS 根 | `~/Desktop/ios-shots/<module>/` |
| H5 | WebView/H5 **禁止截图**，不进 P0 真值与对拍 |

### C.1 复用与压缩

- 目录内已有非空目标 PNG → 默认复用，禁止无故 `FORCE_RECAPTURE`。
- 写出后跑 `compress_png.sh`；默认 `OXIPNG_LEVEL=2`；禁流水线 `-o max`。

### C.2 DEVICE 对拍纪律

- 仅 **merge 之后**，且 **用户/TASK 明确「开 DEVICE」**（或 `DEVICE=go`）。
- 超阈值 → 只改对照表内 KMP/CMP 文件再验；**禁止改 Android/iOS 真值 PNG 或放宽阈值凑绿**。
- 烟测未开 DEVICE 时，可交「编译 + 主路径可走」证据，不得冒充视觉结案。

### C.3 设备

- 真机或已装应用的模拟器；Android 多设备 `ANDROID_SERIAL`；iOS `IOS_UDID`；OHOS 对拍设备与截图真机错峰。
