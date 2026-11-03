# 总览与门禁

## 一句话结论

- **看见什么** → 鸿蒙原生截图（`SHOT_PLATFORM=harmony` / `ohos-native`，默认）
- **怎么算/怎么走** → 鸿蒙原生业务源码：状态机、接口、边界、回写 → 落到 **Kotlin**（优先 `commonMain`）
- **代码怎么放、怎么写** → **只跟目标 KMP 仓既有 source-set / 模块 / DI / 导航**；UI **Compose Multiplatform**，对齐鸿蒙原生观感；壳工程 `harmonyApp` 负责签名 HAP；**禁止改鸿蒙原生仓凑绿**
- **对照鸿蒙原生实现，不要用 Material 默认 / 系统组件或未入仓占位顶替**

三边冲突一律停问产品，禁止「先能跑再倒推期望」。

---

## 0. 开工前齐套（缺一项停 CODE）

### 0.1 输入资产

```text
sync/<module>/
  harmony-shots/     # 权威在桌面 ~/Desktop/harmony-shots/<module>/，不进 git
  logic/             # map.md + notes-state-machine.md（Kotlin 分支表）
  kmp-anchor/        # where-to-put.md（commonMain/ohosMain/feature 模块）+ patterns.md
  shots-manifest.yaml
  mapping-table.md
  expect-actual-inventory.md
  source-set-checklist.md
```

| 资产 | 必须有 |
|---|---|
| 鸿蒙原生截图索引 | 主路径 + 关键态；与 `SHOT_PLATFORM=harmony` 一致 |
| 逻辑源映射 | 入口、API、分支表（可回溯鸿蒙原生源文件:符号） |
| KMP 落点 | 模块 / source set / Compose 入口 / 路由；复用组件名单 |
| 对照点表 | §B 五列齐；无系统替代/待定 |
| CPF 工具链 | §K 最低环境；`CPF_VERSION` 钉扎策略写进 brief |
| 完成定义 | 主路径、分支、烟测/DEVICE、回写 |

### 0.2 向用户确认的最小信息（未知才问，一次 ≤3）

1. **鸿蒙原生模块路径** + **KMP 模块路径**（及 `harmonyApp`）
2. `SHOT_PLATFORM`（默认 harmony）、是否已有深链、测试账号/fixture
3. 本轮切片与是否允许改码/commit；**是否授权「开 DEVICE」**（默认否）
4. 若有存量 ArkTS 岛：哪些必须本轮 Kotlin 化，哪些留 akinterop（§L）

产品对错 / 逻辑分支必须问清（§I）。工程落点仅在真值已齐时可二选一提案。

---

## 1. 真值优先级

| 维度 | 第一真值 | 第二参考 | 禁止 |
|---|---|---|---|
| 布局 / 区块 / 主按钮 / 空态 / 动效观感 | **鸿蒙原生截图 + ArkUI 源** | 与截图一致的设计稿 | 用 KMP 现状或「差不多」当期望；禁系统/Material 顶替；**禁用 Android/iOS 截图当 DEVICE 对比源** |
| 入口参数、状态机、分支、API、回写 | **鸿蒙原生业务源码** | 接口文档；Android/iOS 仅旁证 | 只看 UI 猜逻辑；把 Android ViewModel 类型塞进 commonMain |
| 目录、导航、DI、网络、播放器复用 | 目标 **KMP 仓**同类已有实现 / CPF 示例范式 | 同仓已验收范例 | 镜像原生工程树硬搬；无 CPF 实证的三方强依赖；**改鸿蒙原生仓凑绿** |

冲突：截图有逻辑无 → 澄清；逻辑有截图无 → 补截或标隐藏；组件名不一致 → 用仓内/设计组件实现鸿蒙观感。

---

## 2. 阶段门禁（必须按序；禁止跳步派 CODE）

| 阶段 | 产出 | 放行条件 |
|---|---|---|
| S0 范围 | `CLARIFY_<MODULE>_SCOPE.md` | 非目标、完成定义、硬门；是否开 DEVICE |
| S1 结构 | `CLARIFY_<MODULE>_STRUCTURE.md` | 映射 + 双树（原生+KMP）+ **分支表** + source-set 草图 |
| S2 截图 | 桌面 `harmony-shots` + index | P0 齐；复用优先；`SHOT_PLATFORM=harmony` |
| S2b 对照点 | `mapping-table.md` + expect/actual 清单 | 五列齐；资源缺失已裁定 |
| S3 WBS/PROMPT | 可独立派切片 | Must-fix 三段；白名单 ⊆ 对照表；标明 commonMain/ohosMain |
| S4 STAGE_A | Must-fix、TC、资源核对 | 缺分支表/资源/对照表 → 不派 CODE |
| S5 CODE | 仅表内 **KMP** 文件；遵 A+E+K(+L) | 本机仓；合入后再烟测 |
| S6 DEVICE | KMP 同态还原 vs **harmony-shots** + **≤1%** + 回勾 | **须明确授权**；超 1% → 只改表内 KMP 文件 |
| S7 回灌 | 坑点 | 禁止只对功能不对坑点 |

切片顺序：地图（无码）→ 对照点确认 → 壳+空失败 → 主路径 → 分支 → 视觉 triage → 回写。  
指定整模块另读 **§F**；工具链读 **§K**；存量岛读 **§L**。

---

## 3. 墙钟提速

默认 **§H**（`SPEED=fast`）。点名 `SPEED=full` 才走全文档重量。
