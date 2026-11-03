## E. KMP / CMP 锚点与开发规范（落点 + 转码纪律）

> 目标运行时：CPF-KMP-CMP 上的 **Compose Multiplatform → OHOS**（`harmonyApp` 推包）。  
> 工具链细节见 **§K**；存量 ArkTS 见 **§L**。

### E.1 架构落点（先找同类）

1. 在目标 KMP 模块内找已有 List/Detail/Player/Pay 等 **Compose** 范式；**只扩屏与 API**，不新开「Android 式」包名镜像。
2. 模型与 API：与仓内 `commonMain` data/domain 同风格；字段注释可写「对齐源端 Xxx」。
3. UI 进既有导航图；遵循仓内 Navigation / CPF 文档中的多平台导航范式（若文档写明 Navigation3 + ViewModel 作用域装饰器，按文档接，勿自造第二套）。
4. 跨模块回调用仓内已有结果/回调，**不引入**源端 Delegate 镜像层。
5. 弹框、图标、进度 → **复用仓内 Compose / 设计导出**；禁止系统 Dialog / 系统图标顶替设计稿。
6. 禁止：为同步复制 Android 布局层级或 iOS 文件名；禁止未经批准的平行实现；禁止默认把新 UI 写成 ArkTS。

### E.2 转码原则（对照源码 → Kotlin/Compose，不是字面翻译）

| 做 | 不做 |
|---|---|
| 先写对照点表与映射表再改码 | 按 XML/Storyboard/ArkUI 树逐个翻译 |
| 按用户路径与状态机实现 | 按源端文件名一一建文件 |
| UI 块对齐截图锚点与屏占比 | 用系统控件「看起来像」交差 |
| 逻辑对齐源端分支表（§I） | 只看截图猜接口；stub/假数据交差 |
| 能放 `commonMain` 就放 | Android 类型漏进 common；无边界乱 expect |
| 复用仓内播放器/列表范式 | 无 CPF 实证的三方硬依赖 |

推荐 CODE 顺序：对照点确认 → 路由与参数 → 壳与导航 → 数据与 API（空/失败先接通）→ 主路径 Compose 块 → 分支与回写 → 动效与资源 →（若需）ohosMain actual / akinterop 缝。

### E.3 Source-set 纪律（硬）

| 放哪里 | 放什么 |
|---|---|
| `commonMain` | 业务逻辑、多平台 ViewModel/UseCase、**可共享 Compose UI**、纯 Kotlin 模型 |
| `androidMain` / `iosMain` | 各端专有 I/O、SDK、入口 Activity/桥 |
| `ohosMain` | OHOS 专有：CAPI 封装调用、账号/传感器/文件系统等 actual、ArkTS/NAPI 入口胶水（如 ViewController） |
| `commonTest` | 逻辑单测（分支表可测部分优先） |

硬禁：

- `import android.*` / UIKit / 其它端 SDK 进入 `commonMain`
- 把仅 OHOS 能用的 API 假装成 common API 而不走 expect/接口
- 为「省事」把整页 UI 只写在 `ohosMain` 而 common 留空壳（除非产品裁定单端）

交卷字段 **`SOURCE_SET`** 必须与白名单一致。开工填 `templates/source-set-checklist.md`。

### E.4 expect / actual（硬）

- **仅真平台边界**使用 expect/actual（同包同签名；actual 覆盖各目标）。
- **优先** common 接口 + DI/工厂注入，减少 expect 面。
- 每个新增 expect 必须写入 `templates/expect-actual-inventory.md`（符号、为何不能 common、各端 actual 路径）。
- 禁止「先 expect 一打，再慢慢填 actual」无清单推进。

### E.5 Compose / UI 规范

1. **Compose first**：新 OHOS 目标 UI 用 `compose.ui` / `foundation` / `material` / `material3` 的 **CPF 已提供 OHOS 实现**；版本钉扎见 §K。
2. 几何先验：贴顶/对齐锚点/屏占比对齐截图，再调间距；禁止无真值的经验尺度配方来回打。
3. 状态：VM / 明确 state holder；副作用不在 composition 主路径乱发请求。
4. 列表：懒加载列表 + 稳定 key；与截图分段态可测。
5. 资源：走 **composeResources**（或仓内既定同步到 `harmonyApp` rawfile 的流程）；先入仓再引用；缺资源「缺失，停止」。
6. 字重：见 §B.5；源端非粗禁止擅自 Bold/Medium。
7. 动效：完成回调/动画结束，禁止盲 sleep 当结束。
8. 渲染：API 允许时优先文档所述统一渲染（RenderNode）路径；勿在业务码里私自叉一套渲染后端。
9. 命名跟 KMP 仓约定，不跟 Android/iOS 文件名；默认禁改公共层（A.3.1）。

### E.6 Must-fix 首段模板（视觉/弹框/图标轨）

1. **真值**：对照哪张图 / 逻辑源哪段；弹框=设计或仓内组件；图标=导出路径  
2. **禁区**：禁系统弹框/图标/占位；禁无真值擅自加粗；禁 Android 类型进 commonMain；规格未写「用系统」破禁停手  
3. **证据**：资源已入仓；路径与校验；source-set / expect 清单已更新  

静态编译 PASS ≠ 视觉结案。

### E.7 PROMPT / TASK 必备块

```text
角色与目标
真值（截图号 + 逻辑源符号/API）
对照点表行号（§B）
KMP 落点（模块 / source set / 文件 / 复用 Composable）
禁区（系统弹框/图标/占位/擅自 FontWeight/混轨/未授权 commit/盲 sleep）
证据（资源路径 + SOURCE_SET + EXPECT_ACTUAL）
完成定义 / VC1…
非目标
白名单路径（⊆ 对照表）
约束（Git / 是否可 DEVICE）
回报格式（交卷模板 + CODEGRAPH + 同表回勾）
```

### E.8 DEVICE 与打回

1. 视觉用例表：`用例ID | 截图号 | 操作 | 期望 | 现状`
2. 逻辑用例表：按分支表
3. 对照点表回勾
4. 同主题多轮 → triage；**R3 → §J**
5. OHOS 同态对拍：`scripts/verify_ohos.sh`；默认阈值 **1%**；超差只改表内文件；**禁改真值截图凑绿**
6. **默认等「开 DEVICE」**；未获准则只报告烟测

### E.9 质量门禁清单（派单前自勾）

- [ ] 范围与非目标已确认；DEVICE 授权状态写死  
- [ ] P0 截图齐；桌面根正确；H5 未进真值  
- [ ] 分支表齐；Kotlin 落点与 source-set 草图齐  
- [ ] 对照点五列齐；expect/actual / source-set 清单齐  
- [ ] 字重规则明白；Lottie 时机表（若有）  
- [ ] CODE 遵 A（codegraph/Ponytail/公共层）+ E + I  
- [ ] CPF 版本策略写进 brief（§K）  
- [ ] 触及存量 ArkTS 时 §L 边界清晰  

### E.10 风险默认策略

| 风险 | 策略 |
|---|---|
| 截图不全 | 停 CODE；补态或缩小子集 |
| Android 与逻辑源不一致 | 单列裁定 |
| 无同类 Compose 组件 | 先扩展最近范式；新建须 STAGE_A |
| commonMain 污染平台类型 | 破禁；下沉 ohosMain/接口 |
| 三方无 OHOS target | DEFERRED 或换 CPF 支持面 |
| 未白名单改公共层 | REJECTED |
| 大爆炸 ArkTS 重写 | 强制走 §L + §J EXIT |
