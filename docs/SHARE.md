# 分享文案（P4）

复制即用。按需改链接。

仓库：https://github.com/Seven-second-fish/legacy-delegate  
安装：`npx skills add Seven-second-fish/legacy-delegate -g`  
Demo：https://github.com/Seven-second-fish/cakeshop  
对照动画：[docs/demo-walkthrough.html](demo-walkthrough.html) · [demo-bare-vs-skill.gif](demo-bare-vs-skill.gif)

---

## skills.sh / Agent Skills 目录短贴

```text
legacy-delegate — 遗留仓可审计代工

不熟项目的 AI 常「眼熟就改」。这个 skill 强制 Orient → Map → Change → Leave：
无 Map complete 不准改业务代码，证据 L0 不得宣称完成，产物落在 .delegate/。

npx skills add Seven-second-fish/legacy-delegate -g

真实对照（cakeshop）：空车 NPE 500→302；空车提交 500→200；黄金路径仍成功。
```

---

## Cursor 论坛 / Discord 短贴

```text
分享一个显式调用的 Cursor Skill：legacy-delegate

场景：甩长链路 bug/功能给 AI，又不想它漏层、无证据喊「修好了」。
做法：先画触点与改动边界，再最小改动；支持跨会话续跑与轻量 refactor 闸门。

Repo: https://github.com/Seven-second-fish/legacy-delegate
Demo: https://github.com/Seven-second-fish/cakeshop
本地可打开 docs/demo-walkthrough.html 看裸改 vs 启 skill 轮播对照。
```

---

## 可选第二真实仓

当前黄金路径与 before/after 以 **cakeshop** 为第一真实仓。  
第二仓：欢迎用你的遗留项目跑同一 A/B（裸改一次 / 启 skill 一次），把 `.delegate/` 脱敏后开 Issue/PR；本仓暂不绑定第二个官方 case。

发布勾选（需你本人账号操作）：

- [ ] 发到 skills.sh / 相关目录
- [ ] 发到 Cursor 社区帖
- [ ] （可选）第二真实仓 case Issue
