# L. 鸿蒙原生存量 → akinterop → Kotlin 切片（渐进迁移）

> 鸿蒙原生仓已有 ArkTS/ArkUI 业务与系统能力，本 skill 是把它们**同步进 KMP**，**禁止无范围卡的大爆炸重写**。  
> 互操作权威：CPF **跨语言调用用户手册** + https://gitcode.com/CPF-KMP-CMP/akinterop ；C 侧见 **CAPI 用户手册**。  
> 本层不是「从 Android 迁」；Android/iOS 仅旁证。

## L.0 何时走本层

- 目标能力在鸿蒙原生侧已有 ArkTS/ArkUI 实现，要进 KMP/CMP；或  
- 新逻辑写 Kotlin，但仍须调用存量 ArkTS 模块 / 系统侧能力。

若从零新建且无 ArkTS 债：本层可标 `N/A`，仍建议扫一眼是否误改壳工程或原生仓。

## L.1 策略总则

1. **Compose first 新 UI**：新屏幕优先 `commonMain` Compose，对齐鸿蒙原生观感；不要默认再写一套 ArkUI。  
2. **存量可运行则先桥**：ArkTS 模块继续服役，经 **akinterop** 双向调用，直到按切片抽进 Kotlin。  
3. **切片迁移**：一次一个边界清晰的 UseCase/屏/服务；每片有对照点 + 分支表 + 完成定义。  
4. **大爆炸 = EXIT**：整模块「一周内全改 Kotlin」无 §J/范围卡 → **BLOCKED**，升 EXIT 卡选 B/C/F。  
5. **壳与真值仓**：`harmonyApp` 入口、签名、HAP 管线保持；**鸿蒙原生真值仓只读**（截图/读源），业务改动落 KMP；Kotlin 经 NAPI/ViewController 挂载（见 CPF 示例）。

## L.2 推荐阶段

| 阶段 | 动作 | 完成标准 |
|---|---|---|
| L0 盘点 | 列出鸿蒙原生 ArkTS 文件/能力、调用方、是否 UI | `interop-inventory`（可附在 module-brief） |
| L1 定边界 | 本轮 Kotlin 化范围 vs 保留 ArkTS 岛 | 用户书面确认；DEFERRED 列表 |
| L2 桥 | akinterop 声明 + 生成桥；类型/异常可跨侧传递处按手册测 | 双向烟测通过 |
| L3 抽逻辑 | 状态机/API 进 commonMain；ArkTS 变薄调用方或反过来 | 分支表接通；旧路径开关或双跑 |
| L4 抽 UI | Compose 屏替换 ArkUI 屏；路由切流 | 对照点 P0；获准后 ≤1% vs harmony-shots |
| L5 收岛 | 删除或冻结已迁移 ArkTS（仅在约定范围内）；更新文档 | 无死桥；PUBLIC_IMPACT 若动公共桥 |

## L.3 技术边界（写进 expect-actual / interop 清单）

| 能力 | 倾向 |
|---|---|
| 纯业务计算 / 模型 | commonMain Kotlin |
| 共享 UI | commonMain Compose（对齐鸿蒙原生） |
| 系统能力 / 已有 ArkTS SDK 封装 | 暂留 ArkTS + akinterop；或 CAPI + ohosMain actual |
| 仅 OHOS 文件/传感器 | ohosMain actual |
| 产品强制保留的 ArkUI 岛 | 标 DEFERRED；对照表写明「interop 岛」 |

## L.4 禁令

- 无清单删除大批 ArkTS「以后再补桥」  
- 桥未通就报模块 Done  
- 用假数据冒充已互操作通（§I）  
- 在业务同步单里顺手升级 CPF 大版本  
- **为凑绿改鸿蒙原生真值仓或真值 PNG**  
- 派单文稿讨论实现细节时泄露内部平台/助手名（业务派单保持中性）

## L.5 RESULT 增字段（触及本层时）

```text
INTEROP: none | bridging | migrating-slice | deferred-island
AKINTEROP: yes|no
ARKTS_TOUCHED: <路径列表或 none>
```
