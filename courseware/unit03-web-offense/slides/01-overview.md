---
title: "第三单元: Web 漏洞攻防"
subtitle: "SQLi · XSS · 上传 · CSRF（大纲）"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# U3 Web 漏洞攻防 → capstone M3

> 📝 撰写状态：**大纲**（待增量成文）。来源：Ch6-7 瘦身（Ch7 是巨头，需大幅精简）；讲授 ≤3 学时。

---

## 真实问题

> **如何攻破一个 Web 应用？**

* 先懂杀伤链（Ch6），再逐类拆解 Web 漏洞（Ch7）

---

## 计划 slides（just-in-time）

* 渗透方法论与杀伤链（速览）
* SQL 注入：原理、利用、**参数化修复**
* XSS：反射/存储/DOM、利用、编码防御
* 文件上传漏洞：类型校验、路径穿越
* CSRF 与 SameSite、反序列化等（按需）
* 每类配 PoC + 修复对照

---

## AI 织入（可选）

* AI 辅助生成 payload 变体（绕 WAF）、AI 辅助漏洞挖掘与代码审计（呼应 U6 slides 03）

---

## 能力自评

* 簇 ③·L2：发现并利用 SQLi/XSS/上传/CSRF + PoC → 证据 **M3**

> 深度见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x06.md`、`https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x07.md`；lab 见 `labs/lab03-web-offense.md`。
