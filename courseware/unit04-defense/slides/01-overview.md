---
title: "第四单元: 边界防护构建"
subtitle: "防火墙 · IDS · WAF（大纲）"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# U4 边界防护构建 → capstone M4

> 📝 撰写状态：**大纲**（待增量成文）。来源：Ch8-10（Ch10 加固并入实践）；讲授 ≤2 学时。

---

## 真实问题

> **如何用防火墙 + IDS + WAF 联防？**

* M3 你攻过了；M4 给自己的应用套上纵深防御

---

## 计划 slides（just-in-time）

* 防火墙：包过滤/状态检测，iptables/nftables 规则实战
* IDS：Snort/Suricata 规则编写、命中验证、FPR/FNR 度量
* WAF：拦截 SQLi/XSS 变种
* 应用与运行环境加固（Ch10 并入）：SSH、Web 服务器、容器
* **AI 检测组件埋伏**：预告 U6——给 IDS 叠一个 ML 异常检测

---

## AI 织入（埋伏）

* 在 IDS 基础上引入 **AI 异常检测**（Isolation Forest 打风险分）——为 U6/M6 铺路（螺旋：规则 → AI 增强）

---

## 能力自评

* 簇 ④·L2：配置 iptables/WAF/IDS 规则 → 证据 **M4**

> 深度见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x08.md`、`https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x09.md`、`https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x10.md`；lab 见 `labs/lab04-defense.md`。
