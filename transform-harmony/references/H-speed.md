# H. 墙钟提速（默认 SPEED=fast）

> 目标：在**不取消五轨完成定义**的前提下，砍掉空等、重复截图、过重文档与过早全量对拍。  
> **模块同步默认 `SPEED=fast`**；仅当用户写死 `SPEED=full`、或上一轮 FAST 翻车需严格复盘时用 full。

## H.0 预期

| 模式 | 适用 | 相对 full 墙钟（经验） |
|---|---|---|
| **fast（默认）** | 日常指定模块同步 | 约 **40%–60%**（视是否已有截图、能否深链、切片能否互斥） |
| **full** | 首次无图 / 像素级收口 / 复盘翻车 | 100% 基线 |

不能靠「跳过五轨」偷快：快的是**并行与瘦身**，不是少做轨。

## H.1 时间都耗在哪（对照改法）

| 慢因 | FAST 改法 |
|---|---|
| 开局灌读整份 skill / `_full-archive` | **只 Read 本轮层**：00 摘要 → F →（SHOT 时 C）（CODE 前 A+E+G）（对照表 B）；禁止全文灌入 |
| 先截齐再勘察，串行空等 | **SHOT ‖ SURVEY×逻辑/资源/交互** 同开（路径已知即可；SURVEY 不阻断等截齐） |
| 无故重截、P1 全截 | **已有非空 PNG 必复用**；默认 **仅 P0**（default+主路径关键态）；深链优先于多步 click |
| 对照表求全才开码 | 先出 **P0 瘦表** 即可派首批 CODE；P1/动效行可并行补，**DEVICE 前并表** |
| 单文件也开多 worktree | **&lt;5 文件或单切片 → 禁止 multi-worktree**；≥2 互斥切片才 `parallel=yes` |
| 每改一行全量 ≤1% 对拍 | MERGE 后 **先烟测 1–2 个主路径态**；仅 Must-fix / 超差行跑 `verify_harmony`；禁止循环全量 |
| 多轮澄清空转 | 未知一次 ≤3；能默认则写入 brief 推进；产品对错才停问 |
| RESULT 长叙事 | 交卷用短字段 + 勾选；`CODEGRAPH` / `PONYTAIL` /（若有）`PUBLIC_IMPACT` |

## H.2 FAST 流水线（默认）

```text
T0 brief（≤1 页；写死 SHOT_PLATFORM、module、账号、SPEED=fast）
   │
   ├─‖ T1 SHOT：P0 only；复用优先；深链优先
   └─‖ T2/T3/T4 SURVEY：逻辑分支表 / 资源清单 / 交互矩阵（只读）
   │
   ▼
T5 对照点 **P0 瘦表** 定稿（串行；无系统替代/待定/缺失）
   │
   ├─‖ T6… CODE（互斥白名单；强制 codegraph + Ponytail；默认禁公共层）
   └─‖ （可选）补 P1 对照行 / 次要资源——不挡首批 CODE
   │
   ▼
T-MERGE → T-DEVICE 烟测（主路径 1–2 态）→ 超差只改表内行再验
   │
   ▼
并表 + 五轨勾选 + 短 RESULT（需要像素收口时再对 Must-fix 跑满 ≤1%）
```

### H.2.1 与 F/G 的关系

- 五轨仍须齐；FAST 改的是**何时并行、何时瘦表、何时全量对拍**。
- `parallel` 默认：模块切片 ≥2 且白名单可拆 → **yes**；否则 no。
- DEVICE 仍只能 merge 后、单人占设备；可与「下一模块的 SURVEY」错峰，不可与本模块 SHOT 抢同一对照真机若硬件只有一台（鸿蒙对拍机与 Android 截图机可并行）。

## H.3 FAST 禁令（看起来勤快实则拖慢）

1. 开局 Read `_full-archive` 或整份 references  
2. `FORCE_RECAPTURE` 无源 UI 变更却重截全目录  
3. 对照表 0 行缺口也要再问一轮「要不要做」  
4. 为对齐一个 icon 改 `common/` 公共组件（见 A.3.1）  
5. CODE 未合完就全量 DEVICE  
6. 烟测已过仍对无关页做全量像素扫  

## H.4 full 模式加码（仅点名时）

- P0+P1 截图与对照行一次齐  
- DEVICE 对清单态全量 ≤1%  
- 文档与回勾按 S0–S7 全阶段产物（见 00-overview）

## H.5 派单时一行声明

```text
SPEED=fast | module=<id> | SHOT_PLATFORM=android|ios | parallel=yes|no | P0-only shots | 瘦表先 CODE | DEVICE 先烟测
```
