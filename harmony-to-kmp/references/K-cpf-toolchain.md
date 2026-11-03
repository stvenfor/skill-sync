# K. CPF-KMP-CMP 工具链（环境 / 构建 / 版本）

> **外部权威**：https://gitcode.com/CPF-KMP-CMP/docs  
> 本层只固化「开工检查清单 + 流程衔接」；具体按钮路径、插件包名、版本矩阵以文档与 **版本说明 / release-notes** 为准，**禁止臆造 API**。

组织与相关仓（查阅用）：

| 资源 | URL |
|---|---|
| 文档总览 | https://gitcode.com/CPF-KMP-CMP/docs |
| 目录 | https://gitcode.com/CPF-KMP-CMP/docs/blob/main/zh-cn/目录.md |
| 快速开始 | https://gitcode.com/CPF-KMP-CMP/docs/blob/main/zh-cn/入门/快速开始.md |
| 工具链介绍 | https://gitcode.com/CPF-KMP-CMP/docs/blob/main/zh-cn/入门/工具链介绍.md |
| 版本说明 / release-notes | docs 仓 `zh-cn/入门/版本说明.md`、`zh-cn/release-notes/` |
| akinterop | https://gitcode.com/CPF-KMP-CMP/akinterop |
| 示例 | https://gitcode.com/CPF-KMP-CMP/kmp-cmp-example 、 kmp-thirdlibdemo |
| 工具链插件仓 | https://gitcode.com/CPF-KMP-CMP/ohos-kmp-toolchain |

文档 TOC 常见分类：快速开始、入门指南、工具链、框架/架构、UI、ViewModel、导航、资源、FFI/CAPI、编译构建、调试性能、FAQ、示例工程。

## K.1 环境最低线（对照快速开始）

| 项 | 要求（以文档为准） |
|---|---|
| OS | Windows 10/11、macOS 12+、Ubuntu 20.04+ |
| JDK | **17+**（Android Studio Gradle JDK 切到 17） |
| Android Studio | Hedgehog+（文档亦见更高版本建议）；装 Kotlin / Kotlin Multiplatform |
| 插件 | **KMP OHOS Support**（文档现多离线安装；完整 KMP Android/iOS 体验另需官方 Kotlin Multiplatform 插件） |
| DevEco Studio | **6.0.0+**；HarmonyOS SDK **API 17+** |
| Gradle | **8+** |
| 设备 | HarmonyOS API 17+ 真机或模拟器；调试需华为开发者账号签名 |

`local.properties` 典型键（路径按本机改）：

```properties
local.deveco.path=/Applications/DevEco-Studio.app
```

## K.2 典型工程布局

```text
<repo>/
  gradle/libs.versions.toml          # 版本钉扎（KMP/CMP OH 后缀族）
  <shared 或 composeApp>/
    src/commonMain/…                 # 共享逻辑 + Compose UI + composeResources
    src/androidMain/…
    src/iosMain/…                    # 若启用
    src/ohosMain/…                   # OHOS actual / 入口胶水
  harmonyApp/                        # 鸿蒙壳：hvigor、build-profile.json5、签名、HAP
    entry/…                          # ArkTS 入口、rawfile（含 composeResources 同步目标）等
  androidApp/                        # 可选薄壳
```

判断鸿蒙壳：存在 `hvigorfile.ts` / `build-profile.json5` / `AppScope/app.json5` 等（见工具链介绍）。

## K.3 日常构建 / Run 流

1. **DevEco** 打开 **`harmonyApp`**（不是整个 AS 工程根）→ 配好调试签名（Support HarmonyOS + 自动签名等，以文档为准）→ 保持 DevEco 运行（推包依赖）。
2. **Android Studio** 写 KMP/CMP；选设备与 **harmonyApp** Run 配置 → Run。
3. 插件侧典型阶段：编译 KMP 共享（commonMain + ohosMain）→ 同步产物到 harmonyApp → 编原生/资源 → 打包 HAP → 签名安装 → 启动。

烟测定义（本 skill）：主路径 1–2 态可打开、无崩溃、关键日志无红；**不等于** ≤1% 视觉结案。

## K.4 版本钉扎策略（`CPF_VERSION`）

- **默认**：`follow-notes` —— 以 CPF **版本说明 / 最新 release-notes** 与仓内 `libs.versions.toml` 为准，开写前核对，禁止凭记忆钉旧号。
- **已知主线（撰写时公开信息，须再核实）**：社区首发/主干常见对齐 **KMP 2.2.21-x** 与 **CMP 1.9.2-x**（带 OH/社区后缀）；akinterop 等适配库有独立 tag（如 v1.2.0 适配该族）。**不得把本句当作可粘贴的精确坐标**；RESULT 写实际读到的版本。
- 升级：按官方兼容矩阵；跨大版本须单独 TASK，禁止夹在业务模块同步里暗升。

## K.5 UI / 资源 / 导航（摘要）

- CMP：`compose.ui` / `foundation` / `material` / `material3` 的 OHOS 实现由 CPF 提供；业务优先统一渲染路径（文档/release-notes 所述 RenderNode 融合），勿私叉。
- 资源：`composeResources`；同步到 harmonyApp rawfile 的包名须与生成 `Res` 一致（见示例/社区集成文，以仓内脚本为准）。
- ViewModel：多平台 ViewModel；在 common 中构造需提供 initializer（非 JVM 无反射默认）。若用 Navigation3，按文档为 entry 配置 ViewModelStore / SaveableState 装饰器，避免 VM 作用域错误挂到整应用。

## K.6 FFI / CAPI / 调试

- Kotlin ↔ ArkTS：**akinterop**（注解/生成桥；见 §L 与跨语言手册）。
- 原生 OHOS API：CAPI 封装库 + `ohosMain` actual（见 CAPI 用户手册）。
- 调试：AS 鸿蒙目标断点/日志（工具链介绍）；崩溃与渲染类问题先查 docs FAQ。

## K.7 与本 skill 硬门的衔接

| 技能硬门 | 工具链侧 |
|---|---|
| DEVICE | 须签名 + 设备在线 + 用户授权对拍 |
| SOURCE_SET | 目录必须真实存在于工程；勿假写 ohosMain |
| CPF_VERSION | RESULT 必填；跟 notes 或钉扎 |
| 禁默认实现 | 禁止假设「某三方一定有 OHOS target」；以示例/FAQ 实证 |

## K.8 开工自检（CODE 前）

- [ ] JDK17、AS 插件、DevEco、API17 SDK 可用  
- [ ] `local.deveco.path` 有效；Gradle sync 过  
- [ ] harmonyApp 签名可读；设备可见  
- [ ] 已打开本次对准的 release-notes / 仓内版本目录  
- [ ] 已知本模块是否依赖 akinterop / CAPI  
