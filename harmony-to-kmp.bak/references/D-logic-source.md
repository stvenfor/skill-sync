## D. 逻辑源端勘察（行为真值轨 → Kotlin）

产出 `logic/map.md` + `notes-state-machine.md`（名称可随源端改，内容不可少）：

1. 用户入口 → 路由/参数表
2. 主 VC/Presenter/VM（或等价）与子工厂 → **目标 Kotlin VM / UseCase 草图**
3. 网络：路径、字段、空/失败
4. 完成回写与上下游回调
5. 权限与错误路径
6. **派 CODE 前硬门**：`入口 → 状态/分支 → 成功/失败/空态 → 对应截图号`，每行可回溯 **源文件:符号**
7. 标明拟落 **commonMain vs ohosMain**（I/O、传感器、账号体系等才下沉平台）
8. 勘察结果填入 **§B 对照点表**

### D.1 与 §I / source-set 联锁

- 缺分支表或对照点表 → **停**。
- 分支表有、源码定位无 → 禁止用「按截图猜接口」补全。
- 只实现成功态 → 禁止报逻辑轨完成。
- 交卷必须 `NO_GUESS: yes` + `EVIDENCE_LOGIC: …` + `SOURCE_SET: …`。
- **禁止**把 Android SDK / UIKit 类型写进计划中的 `commonMain` API 面。
