# C. 鸿蒙原生视觉真值轨

视觉真值端由 **`SHOT_PLATFORM=harmony`**（别名 **`ohos-native`**）选定（**默认**）。同一模块一轮只认鸿蒙原生 PNG；**禁止**用 Android/iOS 截图作 DEVICE 对比源。

> **真值采集**：`harmony_shot.sh` / hdc → `~/Desktop/harmony-shots/<module>/<page>.png`（鸿蒙原生前台页）。  
> **DEVICE 对拍**：`verify_ohos.sh` 抓 **KMP/CMP（harmonyApp）前台** 与真值对比；只改表内 KMP 文件；**禁改真值 PNG / 禁改鸿蒙原生仓**。

Android/iOS 的 `capture.sh` / `ios_capture.sh` 仅作可选旁证（共享逻辑/历史），**默认不用**。

## 脚本入口（本 skill）

| 脚本 | 作用 |
|---|---|
| `scripts/harmony_shot.sh` | **真值**：鸿蒙原生 hdc 截图 → `~/Desktop/harmony-shots/<module>/<page>.png` |
| `scripts/run_shots.sh` | 默认 `SHOT_PLATFORM=harmony`，调 `harmony_shot.sh` |
| `scripts/verify_harmony.sh` / `verify_ohos.sh` | 抓 KMP 前台 vs harmony-shots 真值，像素差默认 1% |
| `scripts/compare_shots.py` | 真值 PNG vs KMP 候选 PNG |
| `scripts/compress_png.sh` | PNG 无损压缩（oxipng 默认 **-o 2**） |
| `scripts/capture.sh` | （旁证，默认不用）Android → `android-shots` |
| `scripts/ios_capture.sh` | （旁证，默认不用）iOS → `ios-shots` |
| `scripts/interact.sh` / `ios_interact.sh` | （旁证）到达态辅助 |
| `scripts/measure.py` / `ios_index.sh` | （旁证）测量 / 索引 |

模板：`templates/shots-manifest.example.yaml`。产物**不进 git**。已有 PNG **默认复用**。

### C.0 真机端选择

| 项 | 规则 |
|---|---|
| 选择器 | `SHOT_PLATFORM=harmony`（别名 `ohos-native`）；**默认 harmony** |
| 一轮一真值 | 仅 `harmony-shots`；禁止 Android/iOS PNG 进 DEVICE |
| 鸿蒙原生根 | `~/Desktop/harmony-shots/<module>/` |
| 旁证根（默认不用） | `~/Desktop/android-shots/`、`~/Desktop/ios-shots/` |
| H5 | WebView/H5 **禁止截图**，不进 P0 真值与对拍 |

### C.1 复用与压缩

- 目录内已有非空目标 PNG → 默认复用，禁止无故 `FORCE_RECAPTURE`。
- 写出后跑 `compress_png.sh`；默认 `OXIPNG_LEVEL=2`；禁流水线 `-o max`。
- **禁止改动真值 PNG**（含重命名糊弄、手工涂改凑绿）。

### C.2 DEVICE 对拍纪律

- 仅 **merge 之后**，且 **用户/TASK 明确「开 DEVICE」**（或 `DEVICE=go`）。
- 对比：**KMP 前台** vs **`harmony-shots` 真值**。
- 超阈值 → 只改对照表内 **KMP/CMP** 文件再验；**禁止改真值 PNG、禁止改鸿蒙原生仓、禁止放宽阈值凑绿**。
- 烟测未开 DEVICE 时，可交「编译 + 主路径可走」证据，不得冒充视觉结案。

### C.3 设备

- 鸿蒙真机或已装应用的模拟器；`hdc` 可用。真值采集与 KMP 对拍可错峰（先截原生，再推 KMP 包对拍）。
