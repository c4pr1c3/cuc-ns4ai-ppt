---
title: "第一单元: 安全基线"
subtitle: "鉴权 · 会话 · RBAC · 代理基线（大纲）"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# U1 安全基线 → capstone M1

> 📝 撰写状态：**大纲**（待增量成文）。来源：Ch3 压缩；讲授 ≤1 学时。

---

## 真实问题

> **如何让你的应用避免「入门级」漏洞？**

* M0 你已做完威胁建模；M1 把「基线安全」落到代码与配置上

---

## 计划 slides（just-in-time）

* 鉴权：密码哈希（禁用明文）、失败计数、多因素简介
* 会话管理：安全 cookie、过期、固定会话防护
* 授权：RBAC 模型与最小权限
* 网络与代理基线：暴露面收敛、传输加密
* 常见误区：弱口令、越权、会话固定

---

## AI 织入

* （本单元以经典基线为主；AI 在 U4/U6 出场）

---

## 能力自评

* 簇 ①·L3：设计 RBAC/风险登记表随项目演进 → 证据 **M1**

> 深度理论见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x03.md`；lab 见 `labs/lab01-baseline.md`。
