# J. 多轮不过：退出门与换路（硬）

> 禁止同一主题无限 CODE↔DEVICE 空转。  
> **同主题** = 同一对照点行 / 同一 Must-fix 根因 / 同一 UI 区块（以 triage 标题为准）。

## J.0 轮次计数

| 轮次 | 定义 | 必须动作 |
|---|---|---|
| **R1** | 首轮 CODE 后烟测/DEVICE 未过 | 写清失败点；按 §I 证据返工 |
| **R2** | 同主题第二次未过 | **强制**出 `TRIAGE_<主题>.md`（根因、已试配方、**禁区**、几何三件套）；禁止再直接散单 |
| **R3** | triage 后再改仍未过 | **触发退出门 J.1**；禁止派 R4 同思路 CODE |

烟测失败与满量 ≤1% 失败都计入轮次。换人改码不重置轮次。

## J.1 退出门（R3 必走）

```text
EXIT_GATE: <module> / <主题>
轮次: R3
已试: <R1/R2/R3 各一行：改了什么 → 仍差什么>
根因假设: <当前 triage 认定>
证据: <截图 page×state / 对照点行 / 源文件:符号>
推荐换路: <A/B/C 之一，见 J.2>
备选: <其余>
请选：换路编号 | 或书面授权再试一轮（须写新前提，不得重复旧配方）
在未选定前：ACTIVE=BLOCKED，不改码
```

## J.2 换路菜单

| 代号 | 何时用 | 具体动作 | 完成定义 |
|---|---|---|---|
| **A 攻前提** | 同一几何/皮配方仍翻车 | 重验真值：错端/错态/错账号/对照点写错 | 新真值裁定后轮次清零 |
| **B 缩范围** | 主路径可交、边角拖死 | 标 `DEFERRED`；主路径可 PASS_SMOKE | brief/对照表勾 DEFERRED |
| **C 换实现族** | Compose/OHOS 能力撞墙 | 在**仓内/CPF 示例已有范例**中另选落点（仍禁系统顶替）；可改为 interop 岛（§L）经用户点头 | 新落点行定稿后再 CODE |
| **D 升满量复盘** | 怀疑 FAST 瘦表漏态 | `SPEED=full` | full 产物齐后再计一轮 |
| **E 人工产品裁定** | 三边冲突 | 停问产品；未裁定冻结该行 | 裁定写入 Truth-ID |
| **F 拆出独立切片** | 业务残差与 UI 皮搅单 | 新开逻辑-only 或 UI-only / source-set-only TASK | 两单各自验收 |

**禁止的「假换路」：** 只改 padding 再挂 R4；换执行人不改前提；删真值凑绿；把失败 UI 偷偷改回 ArkTS 却不改对照表。

## J.3 与其它层

- 换路仍受 §I / §E source-set 约束。
- EXIT 未完结前，进展不得写该主题「已对齐」。

## J.4 RESULT / ACTIVE 字段

```text
RETRY_ROUND: R1|R2|R3
TRIAGE_PATH: <若 R2+>
EXIT_GATE: pending|chosen:<A-F>|authorized_R4:<新前提一句话>
```

R3 且 `EXIT_GATE: pending` → ACTIVE 必须 `BLOCKED`。
