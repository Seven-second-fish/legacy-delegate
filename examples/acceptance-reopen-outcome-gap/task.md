# 任务

```yaml
task_slug: profile-menu-export
type: bug
mode: delegate
status: done
fast_path: false
evidence_target: L1
resume: false
last_stage: leave
resume_from: ""
```

## 用户诉求

设置页「个人资料」下拉：点「导出数据」应下载 JSON；首轮只验了下拉能开。

## 成功标准

- [x] 下拉可展开（首轮）
- [x] 点「导出数据」触发下载且内容为当前用户 JSON（追诉后补）
- [x] 无控制台报错

## Fast path（如有）

- 理由：N/A

## 续跑（如有）

- N/A

## 已读仓规

- [x] README — `npm test -- ui`
- 测试：`npm test -- profile-menu`

## 阻塞 / 需用户补充

-

## 备注

- 虚构 Admin SPA；演示首轮成功标准过窄 → 同 slug 追诉。
