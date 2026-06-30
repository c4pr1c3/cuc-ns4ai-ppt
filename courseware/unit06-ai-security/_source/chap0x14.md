---
title: "网络安全（AI 时代版）"
author: 黄玮
output: revealjs::revealjs_presentation
---

# 第十四章 AI 安全导论与治理框架

> 📝 撰写状态：**详细大纲**（待增量成文）。素材基底：[`llm-security.md`](llm-security.html) 前半部分。

---

## 提纲

* 为什么「AI 安全」需要单独成章
* 速通大语言模型基础
* 速通大模型安全基础（对齐 / HHH）
* 学习《人工智能安全治理框架》
* AI 风险分类与生命周期
* 本章与课程主线的关系

---

## 为什么「AI 安全」需要单独成章

* AI 从「工具」变为「系统/Agent」，攻击面质变
* 两条主线：<span style="color:#1a73e8">AI 赋能安全</span>（Ch17）vs <span style="color:#d93025">AI 作为对象</span>（Ch15/16）
* 本章给出**共同基础与治理坐标**，是 Ch15-18 的地基

---

## 速通大语言模型基础（大纲）

* 三大架构分支：Encoder-only（BERT）/ Encoder-Decoder（T5、BART）/ Decoder-only（GPT 系）
* 预训练 → 微调 → 对齐 的训练范式
* 代表性模型谱系与继承关系
* （图文：LLM 进化树，素材见 `images/llm-sec/llm-genealogy.webp`）

---

## 速通大模型安全基础（大纲）

* **对齐（Alignment）**：让模型行为符合人类意图与价值
* **HHH 框架**：Helpful / Honest / Harmless
* 指令微调 vs 有监督微调；RLHF vs SFT
* 为什么「对齐不等于安全」（对齐可被注入绕过，铺垫 Ch15/16）

---

## 学习《人工智能安全治理框架》（大纲）

* AI 系统全生命周期各阶段的安全考量
* 风险分类：**内生安全风险**（模型/数据/算法）vs **衍生安全风险**（滥用/误用）
* 治理原则与责任主体
* 与等级保护、数据安全法等的衔接（讨论）

---

## 本章与课程主线的关系

* 为 Ch15（作为攻击面）/ Ch16（Agent 安全）/ Ch17（赋能）/ Ch18（红队）提供**共同语言**
* 对应能力框架簇 ⑥ 的 **L1 认知**层
* 作品 M6/M7 的理论与合规基础

---

## 待成文要点（撰写路线）

* 补全各 H2 为完整幻灯页（动机→直觉→形式化→实战）
* 加入 1-2 个「对齐失败」案例讨论
* 链接到 [`chap0x15`](chap0x15.html)、[`chap0x16`](chap0x16.html)、[`chap0x17`](chap0x17.html)
