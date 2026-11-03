# source-set 检查 · <module>

| 检查项 | 是/否 | 证据 |
|---|---|---|
| 可共享逻辑是否落在 commonMain |  |  |
| 可共享 Compose UI 是否落在 commonMain |  |  |
| OHOS-only I/O 是否仅在 ohosMain |  |  |
| commonMain 是否零 Android/iOS SDK import |  |  |
| 新增 expect 是否已入 expect-actual-inventory |  |  |
| 白名单路径与 SOURCE_SET 字段一致 |  |  |
| 公共/共享模块改动是否有 PUBLIC_IMPACT |  | N/A\|见 RESULT |
