# 地图

```yaml
status: complete
fast_path: false
```

## 入口

设置页 → `#profile-menu` 按钮 → 下拉项「导出数据」

## 关键路径

1. 点击按钮 → `ProfileMenu.open()`
2. 点击「导出数据」→ `ProfileMenu.onExport()` → `UserApi.exportProfile()`

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| `src/ui/ProfileMenu.tsx` | `onExport` | 菜单项 handler 未绑定 |
| `src/api/user.ts` | `exportProfile` | 下载逻辑 |

## 影响面

- 仅设置页个人资料菜单

## 改动边界

**允许：** 绑定 export handler、补 L1 手工验证

**禁止动：** 账户删除、权限模型

## 已证实

- 下拉展开：`open()` 正常
- 导出项无 handler → 点击无后果（追诉根因）

## 假设

-

## 未知

-

## 待确认问题

-
