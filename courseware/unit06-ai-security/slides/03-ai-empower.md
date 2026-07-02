---
title: "第六单元: AI 赋能与对抗"
subtitle: "AI 赋能安全 · 红队速成"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# 主题 1：为什么要 AI 赋能

---

## 告警洪流

* 中型 SOC 每天**数万~数十万**告警，真阳性常 < 1%
* 人才缺 + 数据爆 → 传统规则/签名**力不从心**
* AI 价值：**速度**（秒级分诊）/ **广度**（长尾未知威胁）/ **语义**（读懂日志代码）

> 把重复、海量、需语义理解的工作交给 AI；把**判断、决策、问责**留给人。

---

## 全景：数据→模型→决策→行动

```
行动 SOAR  ：剧本化响应、隔离、封禁（人在回路）
决策 AI-SOC：告警分诊、优先级、调查摘要（LLM）
模型 检测  ：ML-IDS / 异常 / UEBA / 代码审计
数据 采集  ：流量 / 日志 / 端点 / 代码 / 情报
```

* 工程多为**混合**：小模型检测打分 + LLM 分诊解释

# 主题 2：检测与分诊

---

## 从签名到 ML-IDS

* **误用检测（签名/规则）**：已知坏 → 命中（Snort/Suricata，U4 已用）
* **异常检测（AI）**：学「正常」，偏离即告警 → 发现**未知**
* 互补：签名保下限，异常拓上限

---

## 异常检测直觉

* **Isolation Forest**：随机切分，**异常点更易被孤立**
* **自编码器**：压缩再还原，**还原误差大 = 异常**

```{.python .numberLines}
from sklearn.ensemble import IsolationForest
clf = IsolationForest(contamination=0.01).fit(X_normal)  # 只用正常样本
risk = -clf.score_samples(X_live)   # 越大越异常
```

---

## UEBA 与 AI-SOC

* **UEBA**：把异常具体到**用户/实体**（凌晨海外登录 = 高风险），输出风险评分
* **AI-SOC 分诊**：LLM 对告警归类、合并攻击链、生成调查摘要（要求显式表达不确定性）
* 代表（**国产优先**）：DeepSeek / Qwen / GLM / Kimi 做 AI-SOC 分诊与日志归类；国外仅作对比（Security Copilot、Gemini for Security、Elastic ML）——**本课程接入一律国产**

---

## SOAR：决策→行动（铁律）

* **SOAR**：响应剧本化（钓鱼邮件→提威胁情报指标（IOC）→查情报→命中则隔离+封禁）
* AI 介入：自然语言→剧本、运行中动态调整
* ⚠️ **高风险动作必须「人在回路」**

# 主题 3：渗透·审计·情报

---

## AI 辅助渗透与代码审计

* 侦察：LLM 解读 nmap/子域名结果
* 漏洞：辅助分析反编译、生成攻击载荷（payload）变体（绕 WAF）
* **AI 代码审计**：静态分析器（高精度）+ LLM（高召回）**交叉验证**，修复须人工审查
* ⚠️ 仅限授权范围；课程**不教**编写恶意代码

---

## RAG 威胁情报

* LLM 训练有截止日 → 对新 CVE/新组织无知
* **RAG**：检索情报库 → 拼进提示 → 带引用生成
* ✅ 赋能：自然语言查情报、生成检测规则
* ⚠️ 作为对象：库被投毒 → 输出被污染（课件 02 已述）

---

## AI↔AI 攻防演进

* 攻防都在用 AI：AI 检测 vs AI 生成钓鱼/深度伪造
* → **AI 防御 AI**（深度伪造检测、AI 钓鱼识别）
* 评估 AI 安全产品看：**误报率、可解释性、对抗鲁棒性、人在回路**

# 主题 4：红队速成

---

## AI 红队 ≠ 传统红队

* 目标含**模型行为 / 智能体（Agent）链**，不只网络主机
* 分层评估：模型层 / 应用层 / Agentic 层
* 评测集（自行核证）：AgentDojo、InjecAgent、JailbreakBench
* 度量：攻击成功率（ASR）、鲁棒性曲线、HITL 拦截率

---

## 评估→整改→复测闭环

* 评估脚本/数据/结果**版本化**、可复现
* 与治理框架（课件 01）衔接
* 落到工程：**U7 红蓝对抗**即 Agentic 红队的综合演练场

---

## AI 红队方法论与工具锚点

* **方法论**：[OWASP GenAI Red Teaming Guide](https://github.com/requie/AI-Red-Teaming-Guide)、[awesome-ai-security](https://github.com/ottosulin/awesome-ai-security) / [awesome-genai-security](https://github.com/jassics/awesome-genai-security)
* **自动化评估工具**：[Promptfoo](https://www.promptfoo.dev/)（LLM 测试/红队）、DeepTeam（LLM/智能体红队框架，50+ 漏洞类型）
* **评估基准**：[ExploitGym](https://arxiv.org/abs/2605.11086)（AI 把漏洞变真实攻击）、[CyberGym](https://github.com/sunblaze-ucb/cybergym)、[XBOW validation-benchmarks](https://github.com/xbow-engineering/validation-benchmarks)
* **国内自主智能体标杆**：腾讯云智能渗透赛 TCH、[METATRON](https://github.com/sooryathejas/METATRON)（案例讨论，非教学依赖）

---

## 衔接实验 M6（赋能侧）

* 在你的应用集成一个 **AI 检测组件**（Isolation Forest 打风险分）
* **度量**：Precision/Recall、误报、与纯规则版对比、明确**局限**
* 详见实验 + [`capstone/m6-ai.md`](../../../capstone/m6-ai.md)
