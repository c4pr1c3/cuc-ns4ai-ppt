---
title: "网络安全（AI 时代版）"
subtitle: "课件目录"
author: 黄玮
output: revealjs::revealjs_presentation
---

# 课程入口

* [教学大纲](syllabus.md)（8 单元 · 16 讲授 + 48 实践 · 边学边做）
* [网络安全能力框架 v2](capability-framework.md)
* [综合实践项目总览（capstone，里程碑 M0–M7）](capstone/overview.md)

---

## 实战单元

每个单元 = **真实问题引入 + 实战实验（综合实践项目里程碑）+ 按需讲授课件**。单元目录约定：`courseware/unitNN 名称/{slides,labs}/`。

---

### U0 导论与能力框架 → M0

* [课件](courseware/unit00-intro/slides/01-overview.md) | [实验 M0](courseware/unit00-intro/labs/lab00-threat-model.md) | [Git 指南](courseware/unit00-intro/labs/git-guide.md)

---

### U1 安全基线 → M1

* [课件](courseware/unit01-baseline/slides/01-overview.md) | [实验 M1](courseware/unit01-baseline/labs/lab01-baseline.md) · 来源：教材第 3 章压缩 · 主题：安全基线（鉴权/RBAC/会话）

---

### U2 侦察自动化 → M2

* [课件](courseware/unit02-recon/slides/01-recon.md) | [实验 M2](courseware/unit02-recon/labs/lab02-recon.md) · 来源：教材第 4–5 章（含社工） · 主题：自侦察 + 脚本自动化

---

### U3 Web 漏洞攻防 → M3

* [课件](courseware/unit03-web-offense/slides/01-overview.md) | [实验 M3](courseware/unit03-web-offense/labs/lab03-web-offense.md) · 来源：教材第 6–7 章瘦身 · 主题：漏洞利用（SQLi/XSS/上传/CSRF）

---

### U4 边界防护构建 → M4

* [课件](courseware/unit04-defense/slides/01-overview.md) | [实验 M4](courseware/unit04-defense/labs/lab04-defense.md) · 来源：教材第 8–10 章 · 主题：防火墙/WAF/IDS · **AI 检测组件埋伏**

---

### U5 检测取证欺骗 → M5

* [课件](courseware/unit05-detect-forensics/slides/01-overview.md) | [实验 M5](courseware/unit05-detect-forensics/labs/lab05-forensics.md) · 来源：教材第 11–12 章瘦身 · 主题：日志/取证/蜜罐 · **AI 日志分诊埋伏**

---

### U6 AI 赋能与对抗 → M6 ⭐

* [课件：总览](courseware/unit06-ai-security/slides/01-overview.md) | [课件：AI 作为攻击对象](courseware/unit06-ai-security/slides/02-ai-as-target.md) | [课件：AI 赋能攻防](courseware/unit06-ai-security/slides/03-ai-empower.md) | [实验 M6](courseware/unit06-ai-security/labs/lab06-ai-empower-attack.md)

---

### U7 红蓝对抗综合 → M7

* [课件](courseware/unit07-redblue/slides/01-overview.md) | [实验 M7](courseware/unit07-redblue/labs/lab07-redblue.md) · 来源：贯通全课程 · 主题：红蓝对抗 + 取证复盘 + 自评

---

## 综合实践项目主线

* [作品总览（里程碑 M0–M7 + 量规）](capstone/overview.md)
* [课程评价指南（学生版）](capstone/evaluation-guide.md)
* [里程碑 M6：AI 赋能与对抗](capstone/m6-ai.md)
* [种子工程](https://github.com/)（学生派生起点，目录 `capstone/seed/`）

---

## AI 助学层（`/teachme` 生成）

* [助学层使用说明](study/README.md)
* [U6 学习指南](study/unit06-guide.md) | [U6 题库](study/unit06-quiz.md)
* 经典章按需自学：[cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/)（本仓库不保留副本）

> 构建：`bash build_slides.sh`。
