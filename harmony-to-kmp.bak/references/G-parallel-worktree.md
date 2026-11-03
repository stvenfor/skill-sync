# G. 并行与多 worktree（提速，统一合并）

> 只读勘察可并行；改码用多 worktree + 文件白名单互斥；合并后再烟测/DEVICE。禁止多会话同仓同分支抢写。

## G.0 何时启用

| 场景 | 建议 |
|---|---|
| 整模块五轨、切片 ≥2 且白名单可拆 | **启用**并行 |
| 单切片、文件高度耦合、对照表未确认 | **不**并行改码 |
| 设备稀缺 | 截图与 DEVICE **串行**占设备 |

FAST 默认：切片 ≥2 且可拆 → `parallel=yes`；单切片或 <5 文件 → `parallel=no`。

## G.1 可并行 vs 必须串行

```text
【可并行 · 只读】逻辑勘察 | 资源盘点 | 交互矩阵 | source-set 草图
【串行 · 单人】§B 对照点表定稿 → 切片与白名单
【可并行 · 改码】互斥白名单 CODE（各一 worktree）
         依赖序：逻辑接通 → 资源入仓 → UI 块 → 交互 → interop 缝
【串行 · 收口】merge → 烟测 →（获准）verify_ohos
```

硬禁：两会话写同一文件或未声明共享层；未合完就对拍；用云端改本机仓（用户另说除外）。

## G.2 帽子（认领制，不写死人设）

| 帽子 | 当次只做什么 |
|---|---|
| **SHOT** | capture / ios_capture；oxipng；更新 index；H5 禁截 |
| **SURVEY** | 只读逻辑/资源/交互/source-set；不改业务码 |
| **CODE** | 白名单内改 KMP；强制 codegraph + Ponytail；默认禁公共层 |
| **MERGE** | 合切片分支（一人） |
| **DEVICE** | verify_ohos ≤1%（须授权；merge 后；与 SHOT 错峰） |

派单须写死：`SHOT_PLATFORM`、截图根、各窗帽子、worktree、TASK。

## G.3 multi-worktree 规程（KMP 仓根，本机）

```bash
git worktree add -b sync/<module>/<slice> ../<repo>-wt-<slice> HEAD
# 每 CODE 会话：cd 对应 worktree，只改白名单
```

| 项 | 要求 |
|---|---|
| 分支名 | `sync/<module>/<slice>`（shell/logic/res/ui-*/ix/interop） |
| 白名单 | 交集必须为空；共享文件归基础切片先合 |
| Git | 默认禁 commit/push；按 TASK 可 commit 到切片分支 |
| 清理 | merge 验收后 `git worktree remove …` |

合并序建议：逻辑 → 资源 → UI → 交互 → interop。冲突停问主控。
