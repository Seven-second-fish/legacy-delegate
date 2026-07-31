# 任务

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: done
fast_path: false
evidence_target: L2
resume: true
last_stage: leave
resume_from: ""
```

## 用户诉求

`POST /checkout` 在购物车带优惠券时返回 500。先摸清再修。

## 成功标准

- [x] HTTP 200 + 折扣后总额（不再 500）
- [x] 自动化测试覆盖空/缺失优惠券过期时间

## Fast path（如有）

- 理由：N/A
- 用户指定的文件/符号：

## 续跑（如有）

- 已读的既有产物：会话 1 的 `task.md` / `map.md`（draft）/ `notes.md` 交接
- 为何设此 `resume_from`：交接写明 `map`；Map 尚未 complete
- 使用的交接提示：先补完 Map DoD；complete 前不改代码

## 已读仓规

- [x] README — `npm test`
- 构建：N/A
- 测试：`npm test -- checkout`

## 阻塞 / 需用户补充

-

## 备注

- 会话 2 从 Map 续跑；完成 Map → Change（L2）→ Leave。
