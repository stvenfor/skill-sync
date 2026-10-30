# 模块 brief · <MODULE>

| 字段 | 值 |
|---|---|
| module id | |
| Android 包 / 入口 | |
| 逻辑源路径 | |
| 鸿蒙 feature / 路由 | |
| 本轮切片 | 壳 / 主路径 / 分支 / 动效（圈选） |
| fixture 账号与内容 ID | |
| 真机端 / SHOT_PLATFORM | `android` 或 `ios`（默认 android） |
| 截图根 | android-shots 或 ios-shots（与真机端一致） |
| 设备 | Android serial / iOS udid / 模拟器（已装应用） |

五轨勾选（完成才算模块转换完）：

- [ ] 轨1 截图 P0 齐（或已复用）
- [ ] 轨2 业务逻辑分支表 + 鸿蒙接通
- [ ] 轨3 UI ≤1% 对拍 + 对照表回勾
- [ ] 轨4 资源清单入仓无未裁定缺失
- [ ] 轨5 交互矩阵（含 Lottie）验收
