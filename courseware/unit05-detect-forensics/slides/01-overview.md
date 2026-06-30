---
title: "第五单元: 检测·取证·欺骗"
subtitle: "蜜罐 · 取证 · 日志（大纲）"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# U5 检测取证欺骗 → capstone M5

> 📝 撰写状态：**大纲**（待增量成文）。来源：Ch11-12 瘦身（删早期取证历史）；讲授 ≤2 学时。

---

## 真实问题

> **攻击发生了，如何复盘？**

* 检测到攻击 → 取证溯源 → 用蜜罐诱捕

---

## 计划 slides（just-in-time）

* 蜜罐与蜜网：分类（高/低交互）、部署、LLM 诱饵（可选埋伏）
* 计算机取证：证据保全、流程、playbook（删早期历史/法律条文）
* 集中日志与关联分析（ELK 思路）
* **AI 日志分诊埋伏**：预告 U6——用 LLM 对告警归类/合并攻击链

---

## AI 织入（埋伏）

* LLM 日志分诊（呼应 U6 slides 03）：把海量告警合并为事件、生成调查摘要

---

## 能力自评

* 簇 ⑤·L2：部署蜜罐 + 取证 playbook + 复盘一次攻击 → 证据 **M5**

> 深度见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x11.md`、`https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x12.md`；lab 见 `labs/lab05-forensics.md`。
