# 总览与门禁

## 一句话结论

- **看见什么** → 选定平台（`SHOT_PLATFORM=android|ios`，默认 android）自动截图集
- **怎么算/怎么走** → 逻辑源端源码：状态机、接口、边界、回写 → 落到 **Kotlin**（优先 `commonMain`）
- **代码怎么放、怎么写** → **只跟目标 KMP 仓既有 source-set / 模块 / DI / 导航**；UI **Compose Multiplatform**；壳工程 `harmonyApp` 负责签名 HAP；禁止按 Android Activity / iOS Pod / 纯 ArkTS 目录镜像硬搬
- **对照原项目实现，不要用系统组件或未入仓占位顶替设计稿**

三边冲突一律停问产品，禁止「先能跑再倒推期望」。

---

## 0. 开工前齐套（缺一项停 CODE）

### 0.1 输入资产

```text
sync/<module>/
  android-shots/     # 或 ios-shots/：权威在桌面，不进 git
  logic/             # map.md + notes-state-machine.md（Kotlin 分支表）
  kmp-anchor/        # where-to-put.md（commonMain/ohosMain/feature 模块）+ patterns.md
  shots-manifest.yaml
  mapping-table.md
  expect-actual-inventory.md
  source-set-checklist.md
```

| 资产 | 必须有 |
|---|---|
| 选定平台截图索引 | 主路径 + 关键态；与 `SHOT_PLATFORM` 一致 |
| 逻辑源映射 | 入口、API、分支表（可回溯源文件:符号） |
| KMP 落点 | 模块 / source set / Compose 入口 / 路由；复用组件名单 |
| 对照点表 | §B 五列齐；无系统替代/待定 |
| CPF 工具链 | §K 最低环境；`CPF_VERSION` 钉扎策略写进 brief |
| 完成定义 | 主路径、分支、烟测/DEVICE、回写 |

### 0.2 向用户确认的最小信息（未知才问，一次 ≤3）

1. 模块名与路径（Android、iOS/逻辑源、KMP 模块、`harmonyApp`）
2. `SHOT_PLATFORM`、是否已有深链、测试账号/fixture
3. 本轮切片与是否允许改码/commit；**是否授权「开 DEVICE」**（默认否）
4. 若有存量 ArkTS：哪些必须本轮 Kotlin 化，哪些留 akinterop 岛（§L）

产品对错 / 逻辑分支必须问清（§I）。工程落点仅在真值已齐时可二选一提案。

---

## 1. 真值优先级

| 维度 | 第一真值 | 第二参考 | 禁止 |
|---|---|---|---|
| 布局 / 区块 / 主按钮 / 空态 / 动效观感 | 选定平台截图 | 与截图一致的设计稿 | 用 OHOS 现状或「差不多」当期望；禁系统控件顶替；禁混两端 PNG |
| 入口参数、状态机、分支、API、回写 | 逻辑源端源码 | 接口文档 | 只看 UI 猜逻辑；把 Android ViewModel 类型塞进 commonMain |
| 目录、导航、DI、网络、播放器复用 | 目标 KMP 仓同类已有实现 / CPF 示例范式 | 同仓已验收范例 | 镜像 Android/iOS/ArkTS 工程树；无 CPF 实证的三方强依赖 |

冲突处理同 transform-harmony 精神：截图有逻辑无 → 澄清；逻辑有截图无 → 补截或标隐藏；组件名不一致 → 用仓内/设计组件实现观感。

---

## 2. 阶段门禁（必须按序；禁止跳步派 CODE）

| 阶段 | 产出 | 放行条件 |
|---|---|---|
| S0 范围 | `CLARIFY_<MODULE>_SCOPE.md` | 非目标、完成定义、硬门；是否开 DEVICE |
| S1 结构 | `CLARIFY_<MODULE>_STRUCTURE.md` | 映射 + 双树 + **分支表** + source-set 草图 |
| S2 截图 | 桌面根 + index | P0 齐；复用优先；`SHOT_PLATFORM` 写死 |
| S2b 对照点 | `mapping-table.md` + expect/actual 清单 | 五列齐；资源缺失已裁定 |
| S3 WBS/PROMPT | 可独立派切片 | Must-fix 三段；白名单 ⊆ 对照表；标明 commonMain/ohosMain |
| S4 STAGE_A | Must-fix、TC、资源核对 | 缺分支表/资源/对照表 → 不派 CODE |
| S5 CODE | 仅表内文件；遵 A+E+K(+L) | 本机仓；合入后再烟测 |
| S6 DEVICE | OHOS 同态还原 + **≤1%** + 回勾 | **须明确授权**；超 1% → 只改表内 KMP 文件 |
| S7 回灌 | 坑点 | 禁止只对功能不对坑点 |

切片顺序：地图（无码）→ 对照点确认 → 壳+空失败 → 主路径 → 分支 → 视觉 triage → 回写。  
指定整模块另读 **§F**；工具链读 **§K**；存量 ArkTS 读 **§L**。

---

## 3. 墙钟提速

默认 **§H**（`SPEED=fast`）。点名 `SPEED=full` 才走全文档重量。
