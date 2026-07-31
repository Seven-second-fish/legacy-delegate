# 任务

```yaml
task_slug: extract-apply-coupon-helpers
type: refactor
mode: delegate
status: done
fast_path: false
evidence_target: L2
resume: false
last_stage: leave
resume_from: ""
```

## 用户诉求

轻量重构：把 `PricingService.applyCoupon` 里「是否过期」判断抽成纯函数，行为不变。

## 成功标准

- [x] 对外 checkout / preview 折扣结果与改前一致
- [x] 表征测试改前绿、改后绿
- [x] 无跨模块重设计

## Fast path（如有）

- 理由：N/A
- 用户指定的文件/符号：

## 续跑（如有）

- N/A

## 已读仓规

- [x] README — `npm test`
- 构建：N/A
- 测试：`npm test -- pricing`

## 阻塞 / 需用户补充

-

## 备注

- 虚构小仓走通；仅边界内抽纯函数。
