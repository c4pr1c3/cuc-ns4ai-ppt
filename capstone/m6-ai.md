---
title: "里程碑 M6：AI 赋能与对抗"
author: 黄玮
output: revealjs::revealjs_presentation
---

# 里程碑 M6

## AI 赋能与对抗（作品核心）

---

## 目标（对应能力簇 ⑥ · L2 双向）

在你的靶场 Web 应用上**同时完成两面**：

* <span style="color:#1a73e8">**赋能（AI for Security）**</span>：给系统装上 AI 能力并度量其收益
* <span style="color:#d93025">**对抗（AI as Target）**</span>：攻防这些 AI 能力本身

> 这是整门课**同时命中两大 AI 维度**的唯一里程碑，权重最高（期末 30%）。

---

## 起点（M5 末的系统状态）

* 一个已加固、带 IDS/日志/蜜罐的 Web 应用（M0-M5 成果）
* 集中日志可取；有真实用户行为可观测
* 仓库已就绪：鉴权、暴露面清单、已知漏洞与修复记录

---

## 赋能侧 · 任务一：集成一个 LLM 功能

* 给应用加一个「**智能能力**」，任选其一：
    * 智能客服 / FAQ 问答（基于 RAG）
    * 文档/工单摘要
    * 自然语言查询日志（Text-to-Query）
* 要求：**接外部或本地 LLM**，且有**工具/数据访问**（为对抗侧留攻击面）

```python{.python .numberLines}
# 简化：一个带「读知识库 + 查订单」工具的 Agent 端点
@app.post("/api/agent")
def agent(q: str):
    docs = rag.retrieve(q)              # 受信任？对抗侧会投毒这里
    ans  = llm.chat(q, context=docs, tools=[get_order])  # 工具白名单见护栏
    audit.log(user=current_user, q=q, ans=ans)           # 全链路审计
    return ans
```

---

## 赋能侧 · 任务二：集成一个 AI 检测组件

* 用 **ML-IDS / UEBA / 日志分诊** 提升防御（呼应 [`chap0x17`](../chap0x17.html)）
* 最小实现：对登录/请求行为用 Isolation Forest 打风险分，高分触发告警

```python{.python .numberLines}
from sklearn.entropy  import *  # 占位
from sklearn.ensemble import IsolationForest
# 特征：[小时, 是否国内, 频率, 失败次数]
model = IsolationForest(contamination=0.02).fit(X_normal)
risk  = -model.score_samples(X_live)   # 越大越异常
```

* **必须度量**：Precision/Recall、误报分析、与纯规则版的对比、明确写出**局限**

---

## 对抗侧 · 任务一：攻击 AI 功能（红队）

任选 ≥ 2 类，**写 PoC**，记录「劫持/误导是否成功」：

* **间接提示注入**：在 Agent 会读的文档/评论里藏指令，诱导调用受限工具或泄露数据
* **RAG 投毒 / 向量注入**：往知识库塞恶意文档，误导输出（如「把告警转发到攻击者邮箱」）
* **越狱 / 直接注入**：绕过护栏获取越权回答
* **工具滥用**：诱导 Agent 把只读工具当**外传通道**

> 详见 [`chap0x16`](../chap0x16.html)。所有测试仅限自己的应用。

---

## 对抗侧 · 任务二：加固（防御证据）

* **工具白名单 + 人在回路**：高危动作（外发/删除/特权读）须人工确认
* **数据/控制分离**：不可信内容打标，限制其对指令的影响
* **输出/动作护栏**：拦截非白名单工具调用
* **全链路审计**：哪个工具、读了什么、执行了什么
* **度量**：加固前后的**劫持成功率下降**（给出数字）

```python{.python .numberLines}
ALLOW = {"search", "weather"}; DENY = {"email", "rm", "http_post"}
def guard(a):
    if a.tool in DENY:        return block(a)
    if a.tool not in ALLOW:   return ask_human(a)   # 人在回路
    return run(a)
```

---

## 交付清单

1. **代码**：LLM 功能 + AI 检测组件 + 护栏，集成进应用（仓库 tag `m6`）
2. **攻击 PoC**：≥ 2 类对抗实验的复现步骤与结果
3. **度量报告**：
    * 赋能侧：检测组件的 Precision/Recall、误报、与规则版对比、局限
    * 对抗侧：加固前后劫持成功率对比
4. **能力自评**：本里程碑点亮了 簇⑥ 的哪些级（L1/L2）

---

## 评分量规（M6 局部）

| 维度 | 优秀 | 合格 | 不合格 |
| :-: | :- | :- | :- |
| 赋能完整度 | LLM 功能 + AI 检测均有且集成 | 仅其一 | 无 |
| 度量严谨 | 有数据对比 + 局限分析 | 有基本度量 | 仅「能跑」 |
| 对抗深度 | ≥2 类 PoC + 加固证据 | 1 类 PoC | 无攻击 |
| 加固工程化 | 白名单/HITL/审计齐备 | 部分护栏 | 无加固 |

---

## 常见坑

* ❌ 把 LLM 功能做成「纯聊天」、不接任何工具/数据 → 对抗侧无攻击面
* ❌ 只做赋能、不做对抗（或反之）→ 拿不到簇⑥ 双向分
* ❌ AI 检测只报「准确率」不报误报 → 不可用
* ❌ 加固只靠「提示词里写不要被注入」→ 间接注入普遍绕过
