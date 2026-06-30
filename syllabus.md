---
title: "网络安全（AI 时代版）· 教学大纲"
subtitle: "8 个实战单元 · 边学边做"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# 课程定位

---

## 面向 AI 时代的攻防实战课

* **对象**：网络空间安全专业本科生
* **范式**：**减少课堂纯知识讲授**，让学生在解决实际/实战问题中**边学边做、边做边学**
* **主线**：整学期演进**一个「含 AI 能力的靶场 Web 应用」**（capstone M0-M7），知识按需、实战驱动
* **AI 双向**：<span style="color:#1a73e8">AI 赋能安全</span> + <span style="color:#d93025">AI 作为安全对象</span>，织入 U6 专题与 U4/U5 埋伏

---

## 前瞻性对标（政策与行业）

* 对标教育部「**人工智能赋能教育行动**」与 OBE（成果导向）反向设计
* 对标《**AI 时代网络安全产业人才发展报告（2025）**》：全国 65.9% 高校已新增 AI 安全课（↑15pp）；本课彻底 **整课重构 + 边学边做范式**（领先一个身位）
* 对标报告「**AI 驱动网安岗位图谱**」（智能体架构师 / 模型安全红队 / AI 风险顾问）→ 见 [`capability-framework.md`](capability-framework.html) 就业映射
* 海外基准：Stanford XACS134、UCSD CSE291(LLM Security)、Berkeley CS294(Agentic AI)、SANS SEC536/545、UMN ST5663(Red Teaming AI)

---

## 学时（16 讲授 + 48 实践）

| 类别 | 学时 | 占比 |
| :-: | :-: | :-: |
| 课堂 just-in-time 讲授 | 16 | 25% |
| 实战 / 实验 / 作品 | 48 | 75% |
| **合计** | **64** | 100% |

> 趋势：讲授学时**将继续精简**，实践比重进一步提升。

---

## 先修与环境

* **先修**：计算机网络安全、计算机网络 A、Linux 系统与网络管理、Python 编程
* **环境**：Kali Linux、VirtualBox/Docker、大语言模型 API / 本地推理
* **助学层**：`study/`（teachme 学习指南 + 题库）；经典理论按需自学见 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/)

# 八大实战单元

---

## 单元 = 问题 hook + 实战 lab + just-in-time 讲授

| 单元 | 真实问题 | lab(capstone) | 讲授 | 来源 | AI |
| :-: | :- | :-: | :-: | :-: | :-: |
| U0 导论与能力框架 | 如何系统攻防一个真实系统？ | M0 立项+威胁建模 | 1h | Ch1-2 压缩 | — |
| U1 安全基线 | 如何避免入门级漏洞？ | M1 安全基线 | 1h | Ch3 压缩 | — |
| U2 侦察自动化 | 攻击者如何踩点？ | M2 自侦察 | 2h | Ch4-5(+社工) | 可选 |
| U3 Web 漏洞攻防 | 如何攻破一个 Web 应用？ | M3 漏洞利用 | 3h | Ch6-7 瘦身 | 可选 |
| U4 边界防护构建 | 如何防火墙+IDS+WAF 联防？ | M4 加固与边界 | 2h | Ch8-10 | **埋伏** |
| U5 检测取证欺骗 | 如何复盘一次攻击？ | M5 日志取证蜜罐 | 2h | Ch11-12 瘦身 | **埋伏** |
| U6 AI 赋能与对抗 | 如何给系统装 AI 并攻防它？ | M6 AI 赋能对抗 | 3h | Ch14-18 脊柱 | **核心** |
| U7 红蓝对抗综合 | 全流程红蓝对抗如何打？ | M7 红蓝对抗 | 2h | 全课程 | 评估 |
| | | | **16h** | | |

> 详细单元卡片见 [`index.md`](index.html)；能力映射见 [`capability-framework.md`](capability-framework.html)。

---

## 范式要点：为什么是「单元」而非「章」

* 经典 13 章完整讲授 ≈ **33 学时**（仅 Web 章约 6 学时），**2 倍超预算**
* 单元化后：经典知识只保留「做 M0-M7 所需」最小集；深度理论见 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/) 按需自学
* 每个单元以**真实问题**开场 → 紧接 lab → 仅补「做出来所需」的最小讲授
* AI 螺旋：U4/U5 传统方法 → AI 增强（埋伏）→ U6 AI 对抗（集中）

# 考核方式

---

## 渐进式作品（capstone）= 学期主线

* **期末 60%**：M0-M7 渐进式「含 AI 的靶场 Web 应用」，按里程碑 sprint 评分（量规绑定能力簇×级）
* **平时 20%**：课堂快问快答 + 讨论区 + 助学层题库完成度
* **考勤 10%** / **线上 10%**（取自 `study/*-quiz.md`）
* **M7**：红蓝对抗 + 取证复盘 + 能力框架自评矩阵收口
* 详见 [`capstone/overview.md`](capstone/overview.html)

# 撰写路线图

---

## ✅ 已完成 / 📝 待增量撰写

* ✅ 构建迁移（Linux4AI reveal.js 5.x + linux4ai.css + build_slides.sh）
* ✅ 骨架：8 单元 {slides,labs}；经典资料改在线引用（cuc-ns-ppt）；能力框架重映射
* ✅ **U6 AI 赋能与对抗**（旗舰样板，slides + labs）
* ✅ **U0 导论与能力框架**（旗舰样板，slides + labs）
* 📝 U1 / U3 / U4 / U5 / U7：slides + labs 详细大纲（见各单元 `_outline` 或本大纲）
* 📝 其余单元的 `study/unitNN-{guide,quiz}.md`（teachme 按模板生成）

> 经典章全文见 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/) 按需自学；本仓库不再保留副本。
