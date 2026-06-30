---
title: "网络安全（AI 时代版）"
subtitle: "课件目录"
author: 黄玮
output: revealjs::revealjs_presentation
---

# 课程入口

* [教学大纲](syllabus.md.v4.html)（8 单元 · 16 讲授 + 48 实践 · 边学边做）
* [网络安全能力框架 v2](capability-framework.md.v4.html)
* [渐进式作品总览（capstone M0-M7）](capstone/overview.md.v4.html)

---

## 实战单元（courseware/unitNN/{slides,labs}）

每个单元 = **真实问题 hook + 实战 lab（capstone 里程碑）+ just-in-time 讲授 slides**。

---

### U0 导论与能力框架 → M0

* [slides](courseware/unit00-intro/slides/01-overview.md.v4.html) | [lab M0](courseware/unit00-intro/labs/lab00-threat-model.md.v4.html)

---

### U1 安全基线 → M1 📝

* 来源：Ch3 压缩 · lab：M1 安全基线（鉴权/RBAC/会话）

---

### U2 侦察自动化 → M2 📝

* 来源：Ch4-5(+社工) · lab：M2 自侦察 + 脚本

---

### U3 Web 漏洞攻防 → M3 📝

* 来源：Ch6-7 瘦身 · lab：M3 漏洞利用（SQLi/XSS/上传/CSRF）

---

### U4 边界防护构建 → M4 📝

* 来源：Ch8-10 · lab：M4 防火墙/WAF/IDS · **AI 检测组件埋伏**

---

### U5 检测取证欺骗 → M5 📝

* 来源：Ch11-12 瘦身 · lab：M5 日志/取证/蜜罐 · **AI 日志分诊埋伏**

---

### U6 AI 赋能与对抗 → M6 ⭐

* [slides](courseware/unit06-ai-security/slides/01-overview.md.v4.html) | [lab M6](courseware/unit06-ai-security/labs/lab06-ai-empower-attack.md.v4.html)

---

### U7 红蓝对抗综合 → M7 📝

* 来源：全课程 · lab：M7 红蓝对抗 + 取证复盘 + 自评

---

## capstone 作品主线

* [作品总览（M0-M7 + 量规）](capstone/overview.md.v4.html)
* [里程碑 M6：AI 赋能与对抗](capstone/m6-ai.md.v4.html)
* [种子工程（学生 fork 起点）](https://github.com/)（`capstone/seed/`）

---

## AI 助学层（`/teachme` 生成）

* [助学层使用说明](study/README.md.v4.html)
* 经典章按需自学：[cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/)（本仓库不保留副本）

> 📝 = 待增量撰写（详见 `syllabus.md` 撰写路线图）。构建：`bash build_slides.sh`。
