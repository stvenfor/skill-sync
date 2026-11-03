# H. 墙钟提速（默认 SPEED=fast）

> 目标：在**不取消五轨完成定义**的前提下，砍掉空等、重复截图、过重文档与过早全量对拍。  
> **模块同步默认 `SPEED=fast`**；仅当用户写死 `SPEED=full`、或上一轮 FAST 翻车需严格复盘时用 full。

## H.0 预期

| 模式 | 适用 | 相对 full 墙钟（经验） |
|---|---|---|
| **fast（默认）** | 日常指定模块同步 | 约 **40%–60%** |
| **full** | 首次无图 / 像素级收口 / 复盘翻车 | 100% 基线 |

不能靠「跳过五轨」偷快：快的是**并行与瘦身**，不是少做轨。

## H.1 时间都耗在哪（对照改法）

| 慢因 | FAST 改法 |
|---|---|
| 开局灌读整份 skill | **只 Read 本轮层**：00 → F →（SHOT 时 C）（CODE 前 A+E+G+K/L）（对照表 B）；禁止全文灌入 |
| 先截齐再勘察 | **SHOT ‖ SURVEY×逻辑/资源/交互** 同开 |
| 无故重截、P1 全截 | **已有非空 PNG 必复用**；默认 **仅 P0**；深链优先 |
| 对照表求全才开码 | 先出 **P0 瘦表** 即可派首批 CODE；DEVICE 前并表 |
| 单文件也开多 worktree | **<5 文件或单切片 → 禁止 multi-worktree** |
| 每改一行全量 ≤1% | MERGE 后 **先烟测 1–2 态**；仅 Must-fix/超差再 `verify_ohos`；**未获准不开 DEVICE** |
| 每张 PNG `oxipng -o max` | **默认 `-o 2`**；批量一次 `compress_png.sh` |
| 为赶 FAST 瞎猜/stub | **禁止**；§I 优先于墙钟 |
| 同主题 R3 后仍硬刚 | 走 §J 退出门 |

## H.2 FAST 流水线（默认）

```text
T0 brief（≤1 页；SHOT_PLATFORM、module、账号、SPEED=fast、DEVICE=wait|go）
   │
   ├─‖ T1 SHOT：P0 only；复用优先；深链优先
   └─‖ T2/T3/T4 SURVEY：逻辑分支表 / 资源 / 交互 / source-set 草图
   │
   ▼
T5 对照点 **P0 瘦表** 定稿（串行）
   │
   ├─‖ T6… CODE（互斥白名单；codegraph + Ponytail；禁公共层）
   └─‖ （可选）补 P1 —— 不挡首批 CODE
   │
   ▼
T-MERGE → 烟测（harmonyApp 主路径 1–2 态）
   │
   ▼（仅 DEVICE=go / 用户「开 DEVICE」）
verify_ohos ≤1% → 并表 + 短 RESULT
```

## H.3 FAST 禁令

1. 开局灌全文 references  
2. 无源 UI 变更却 `FORCE_RECAPTURE` 整目录  
3. 对照表 0 缺口仍空转澄清  
4. 为对齐一个 icon 改 shared design-system（见 A.3.1）  
5. CODE 未合完就全量 DEVICE  
6. 未获准 DEVICE 却宣称视觉结案  
7. 流水线默认 `oxipng -o max`  
8. 为赶 FAST 瞎猜或 stub（§I）  
9. 同主题 R3 后不走退出门（§J）  
10. 把本应 `commonMain` 的 UI 整段丢进 `ohosMain`「图省事」  

## H.4 full 模式加码（仅点名时）

- P0+P1 截图与对照行一次齐  
- 获准后 DEVICE 对清单态全量 ≤1%  
- 文档与回勾按 S0–S7 全阶段产物  

## H.5 派单时一行声明

```text
SPEED=fast | module=<id> | SHOT_PLATFORM=harmony | parallel=yes|no | P0-only shots | 瘦表先 CODE | DEVICE=wait|go | CPF_VERSION=<follow-notes|钉扎号>
```
