# 改动

```yaml
type: bug
evidence_grade: L1
status: verified
```

## 计划（对齐 Map 边界）

1. 首轮：确认下拉 DOM 与 `open()` 行为
2. 追诉：绑定 `onExport` → `UserApi.exportProfile()`

## 已测假设（bug）/ 触点计划（feature|refactor）

| 项 | 结果 |
|----|------|
| 下拉可展开 | 通过（首轮） |
| 导出项触发下载 | 通过（追诉 #1） |

## 表征证据（refactor 必填；其他类型写 N/A）

- N/A

## 回滚点（refactor 必填；其他类型写 N/A）

- N/A

## 改动摘要

| 文件 | 改动 |
|------|------|
| `src/ui/ProfileMenu.tsx` | 首轮无改；追诉绑定 `onExport` |

## 验证

### 步骤

1. 打开设置页，点个人资料按钮
2. 观察下拉是否展开

### 之前

- 下拉未实现时：无菜单

### 之后

- 下拉展开，三项可见（首轮据此宣称 done — 成功标准过窄）

### 命令 / 测试 / 日志（脱敏）

```
npm test -- profile-menu  # open 用例绿
```

## 追诉 #1

<!-- 用户：「下拉能开，但点导出没反应」；同 slug 重开，不新开 change 文件 -->

### 步骤

1. 展开下拉，点「导出数据」
2. 检查是否下载 `profile-export.json` 且含 `userId`

### 之前

- 点击无下载、无网络请求

### 之后

- 下载触发，`Content-Type: application/json`，体含当前用户字段

## 证据等级说明

- 手工 L1；无 E2E 自动化

## 残留风险

- 大文件导出超时未测
