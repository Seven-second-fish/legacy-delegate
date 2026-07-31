# 任务

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: in_progress
fast_path: false
evidence_target: L2
resume: false
last_stage: orient
resume_from: map
```

## 用户诉求

`POST /checkout` 在购物车带优惠券时返回 500。先摸清再修。

## 成功标准

- [ ] HTTP 200 + 折扣后总额（不再 500）
- [ ] 自动化测试覆盖空/缺失优惠券过期时间

## Fast path（如有）

- 理由：N/A
- 用户指定的文件/符号：

## 续跑（如有）

- 已读的既有产物：N/A（首会话）
- 为何设此 `resume_from`：N/A
- 使用的交接提示：N/A

## 已读仓规

- [x] README — `npm test`
- 构建：N/A
- 测试：`npm test -- checkout`

## 阻塞 / 需用户补充

-

## 备注

- 会话 1 因上下文停在 Map 半程。交接见 notes.md。
