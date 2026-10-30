## 3. Android 自动截图（视觉真值轨）

## 脚本入口（本 skill）

相对 skill 根目录：

| 脚本 | 作用 |
|---|---|
| `scripts/capture.sh` | 真机/模拟器前台页 → PNG+控件树+测量表 → `~/Desktop/android-shots/<module>/` |
| `scripts/measure.py` | uiautomator XML → dp 表 |
| `scripts/run_shots.sh` | 模块目录引导 / 单页封装 |
| `scripts/ios_index.sh` | iOS 关键词只读索引 |
| `scripts/harmony_shot.sh` | 鸿蒙 hdc 截图并排 |
| `scripts/interact.sh` | 点击 / 滑动 / 长按（adb input） |
| `scripts/compare_shots.py` | Android vs 鸿蒙像素差（默认阈值 1%） |
| `scripts/verify_harmony.sh` | 鸿蒙同态截图 + 对比；超阈值提示同步优化 |

模板：`templates/shots-manifest.example.yaml`。产物**不进 git**。已有 PNG **默认复用**。

---


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

### 3.9 已有截图优先（禁止无故重截）

1. 跑截图前先查 `~/Desktop/android-shots/<module>/`（及 index）：目标 `file` **已存在且非空** → **默认复用**，记 `SKIP_EXISTING`，不调 adb/hdc 重截。
2. 仅在以下情况重截：`FORCE_RECAPTURE=1` / `--force`；或 index 标注「源 UI 变更须刷新」；或文件损坏/0 字节。
3. `scripts/capture.sh` 已实现上述 SKIP；Runner / Instrumentation 路径须同等实现（manifest 可写 `reuse: prefer_existing`，默认 true）。
4. 复用时仍须核对：文件名与 `page+state` 对应、分辨率 profile 与本轮 DEVICE 一致；profile 变了才允许重截并更新 index。

### 3.10 点击 / 拖动等交互（评估结论：支持）

| 能力 | 支持度 | 做法 |
|---|---|---|
| 单击 / 双击近似 | **支持** | manifest `actions[]: click`；或 `scripts/interact.sh tap` / `tap_pct` |
| 滑动 / 拖动 | **支持** | `swipe` / `swipe_pct`；清单优先 `scroll_to_*` / `scroll_until` |
| 长按 | **支持** | `longpress`（input swipe 同点延时） |
| 多指 / 复杂系统手势 | **有限** | 不保证；能深链直达态则勿用手势凑 |
| 依赖动画中间帧 | **谨慎** | 截「拖前/拖后」两态；残影一般不进 P0 |

硬规则：

- 交互写进 **shots-manifest `actions[]`**（可重复、可过滤），禁止口头「先随便点一下」。
- 坐标优先 **resource-id / testTag 定位后点中心**；百分比坐标仅兜底并写进 note。
- 每关键态仍 **一态一图**；交互是到达该态的路径，不是用录像替代截图。
- adb `input` 为过渡通路；稳定后迁 Instrumentation（与 §3.1 一致）。

### 3.11 鸿蒙真机还原验证与 ≤1% 差异门

Android 截图齐套（或复用完成）后，**必须**在鸿蒙真机按同一入口/态还原并截图对拍：

```text
Android 真值 PNG
    → 鸿蒙打开同态（深链 / 同操作路径）
    → scripts/harmony_shot.sh
    → scripts/compare_shots.py（默认 threshold=0.01）
    → scripts/verify_harmony.sh <page> <module>
```

| 结果 | 动作 |
|---|---|
| 差异像素占比 **≤ 1%** | DEVICE 该态 PASS（仍须对照点表语义回勾） |
| 差异 **> 1%** | **同步优化**：对照点表回勾差异 → 只改表内鸿蒙文件 → 重编装 → 再 `verify_harmony`；禁止改 Android 真值凑绿 |
| 缺 Android 真值 | 先 §3.9 复用或补截，禁止只截鸿蒙空比 |

排除（不进 1% 像素门，须在 index/note 标明）：状态栏/刘海、系统字体缩放、stitch 附录、随机波形/未钉死 Lottie 帧。P0 主路径与关键弹层**不得**借排除项逃门。

落盘：`$OUT/<page>.harmony.png` + `<page>.compare.json`（不做 git 管理）。
