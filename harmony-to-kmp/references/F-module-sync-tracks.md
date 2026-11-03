# F. 指定模块同步总轨（截图 → 逻辑 / UI / 资源 / 交互）

> 用户点名「把某某鸿蒙原生模块同步到 KMP」时，**本层是执行清单**。五轨都要做完才算完成。  
> 硬保证：§I；缺证据不得 CODE。视觉真值：`SHOT_PLATFORM=harmony`（§C）。

## F.0 入口（一次收齐）

写入 `templates/module-brief.md` 副本（对话/TASK，不进业务仓 skill 镜像）：

| 字段 | 必填 |
|---|---|
| 模块名 `<module>` | 与桌面 `harmony-shots/<module>/` 一致 |
| `SHOT_PLATFORM` | harmony（别名 ohos-native；默认） |
| **鸿蒙原生工程/模块路径** | 真值仓与入口页 |
| **KMP 工程/模块路径** | commonMain / ohosMain / feature |
| `harmonyApp` 路径 | 壳与签名 |
| 逻辑源路径 | 默认同鸿蒙原生业务代码 |
| 存量 ArkTS 岛边界 | 无 \| 桥接清单（§L） |
| 本轮切片 | 壳→主路径→分支→动效；禁一单糊完 |
| `DEVICE` | wait（默认）\| go |
| `CPF_VERSION` | follow-notes 或钉扎 |
| 账号与 fixture | 可固定内容 ID |

未知才问，一次 ≤3。

## F.1 五轨（必须全覆盖）

| 轨 | 真值 | 必做 | 完成标准 |
|---|---|---|---|
| **1 截图** | **鸿蒙原生**可见态 | Read §C；复用优先 | P0 `page×state` 齐；`~/Desktop/harmony-shots/<module>/` |
| **2 业务逻辑** | **鸿蒙原生**源码 | Read §D + §I；分支表可回溯；Kotlin 接通 | 失败/空/权限态齐；`NO_GUESS`/`EVIDENCE_LOGIC`/`SOURCE_SET` |
| **3 UI 效果** | 鸿蒙截图 + 对照点 | Read §B/§E；Compose 改表内 **KMP** 文件 | 获准后 `verify_ohos` **≤1%**（vs harmony-shots）；同表回勾 |
| **4 资源** | 鸿蒙原生/设计导出 | `resource-inventory.md`；composeResources 入仓 | 无未裁定「缺失，停止」 |
| **5 交互效果** | 鸿蒙原生手势/动效 | `interaction-matrix.md`；§B.4 | 时机与源一致；禁盲 sleep |

依赖顺序（默认 SPEED=fast）：

```text
F.0 brief（SPEED、SHOT_PLATFORM=harmony、DEVICE、CPF_VERSION、原生路径、KMP 路径）
  → 轨1 截图（P0） ‖ 轨2/4/5 只读勘察 ‖ source-set/expect 草图
  → 对照点 P0 瘦表【串行】
  → CODE：互斥白名单 → multi-worktree（≥2 切片）；codegraph + Ponytail；禁公共层；只改 KMP
  → merge → 烟测
  →（DEVICE=go）verify_ohos ≤1%
```

## F.2 与阶段门禁

| 五轨 | 主要阶段 |
|---|---|
| 轨1 | S2 |
| 轨2 | S1 + S4 |
| 轨4 / 轨5 | S2b + S4 |
| 轨3 | S5 + S6 |
| 全轨回勾 | S6 / S7 |

缺任一轨完成证据 → 不得报「模块已同步完成」。

## F.3 禁止

- 只截图不对拍、不改 KMP  
- 只改 UI 不接通逻辑/回写  
- 资源用系统符号或灰块顶替；Material 默认顶替鸿蒙设计  
- 交互凭感觉不写矩阵  
- skill 脚本/文档拷进业务仓  
- 对 H5 截图或要求原生对拍  
- 默认 DEVICE 未授权却宣称视觉 Done  
- 用 Android/iOS 截图当 DEVICE 对比源  
- 改鸿蒙原生仓或真值 PNG 凑绿  
- 无 EXIT 大爆炸重写 ArkTS  

## F.4 提速

默认 `references/H-speed.md`。点名 `SPEED=full` 时恢复截齐再勘、全表再码、获准后全量 ≤1%。
