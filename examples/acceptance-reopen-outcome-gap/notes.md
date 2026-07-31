# 笔记

```yaml
task_slug: profile-menu-export
type: bug
```

## 改了什么

- 首轮：无代码改动，仅验证下拉展开
- 追诉：`ProfileMenu` 绑定 `onExport` → `UserApi.exportProfile()`

## 如何回归

1. 设置页 → 个人资料 → 「导出数据」→ 确认 JSON 下载
2. `npm test -- profile-menu`

## 成功标准对照

| 成功标准 | 满足 | 证据 |
|----------|------|------|
| 下拉可展开 | ✓ | change 验证 / 首轮步骤 |
| 导出触发下载 | ✓ | change 追诉 #1 / `ProfileMenu.tsx:42` |
| 无控制台报错 | ✓ | 追诉 #1 之后 |

## 给下一位人 / Agent

- 首轮 done 时仅验「可操作态」，漏「意图动作→后果」链；追诉勿新 slug

## 续跑交接

- N/A

## 仍未知

- 导出 >5MB 时的 UX

## 后续

- 可选补 E2E：`profile-menu.spec.ts`

## 文档更新（仅当用户要求）

- N/A
