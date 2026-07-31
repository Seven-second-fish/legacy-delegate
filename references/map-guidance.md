# Map 指引

地图保持**任务范围**。不要整仓考古。

## 建议顺序

1. 定位症状或功能区的运行时/配置入口
2. 沿一条关键路径留下 文件:符号 面包屑
3. 列出最热符号的 fan-in 调用方（影响面）
4. 区分已证实事实与猜测
5. 改码前冻结较小的改动边界

## 好的路径写法

`HTTP /login` → `AuthController.login` → `SessionService.create` → `RedisStore.set` → 失败于 TTL 配置

## 差的地图

- 只有目录树倾倒
- 「感觉是鉴权问题」却无文件
- Unknowns 仍挡住修复却标 `complete`，也不问用户

## 深度与模式

- `delegate`：能支撑可审改动的最短路径
- `onboard`：同路径 + 每一跳一句角色说明
