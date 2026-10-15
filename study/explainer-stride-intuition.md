---
title: "STRIDE 威胁建模的实战直觉"
author: 黄玮
---

# STRIDE 威胁建模的实战直觉

> 这是 **U0 / M0** 的基石技能。课件只能给定义表，这篇把它讲成「**你能上手用的思维工具**」——做完 M0 的 `stride.md`，你就在用 STRIDE。

---

## 1. 动机：STRIDE 是被「拍脑袋漏威胁」逼出来的

威胁建模最大的敌人不是「想不出威胁」，而是**漏掉某一类**。1999 年微软的 Loren Kohnfelder 提出 STRIDE，目的只有一个：**给你一张「不漏」的清单**——把「坏事」分成 6 个互斥又穷举的类，逼你对每个组件/数据流**逐一过一遍**，不靠灵感、不靠经验、不漏类。

**反事实**：没有 STRIDE，新手做威胁建模往往只想到「攻击者会注入」(Tampering) 或「数据会泄露」(Information Disclosure)，**漏掉 Repudiation（赖账）和 Denial of Service（搞挂）**——而本课 M0 的 medium 档样本恰好就是漏了这两类（见 `lab00` 与校准语料）。STRIDE 的价值就是「**用清单代替记忆**」。

---

## 2. 直觉：6 个「坏事」对应 6 个「安全目标」

STRIDE 的 6 个字母，每个对应一个**你熟悉的 CIA / 扩充属性**——一旦建立这个映射，就不用死记：

| STRIDE | 坏事一句话 | 破坏的安全属性 | 课程锚点（`capstone/seed/app.py`） |
|---|---|---|---|
| **S**poofing 假冒 | 「我不是我，我是别人」 | **认证**（Authentication） | `/login` 明文弱口令 `USERS={admin:admin123}`，可爆破冒充 |
| **T**ampering 篡改 | 「我改了你的数据」 | **完整性**（Integrity） | `/orders` SQL 拼接，`'; UPDATE orders --` 改订单 |
| **R**epudiation 否认 | 「这事我没干过」 | **不可抵赖/审计**（Accountability） | `AUDIT` 日志只记 info/warning，缺 user/tool 完整链路 → 操作可抵赖 |
| **I**nformation Disclosure 信息泄露 | 「我看到了不该看的」 | **机密性**（Confidentiality） | `secret_key` 硬编码 + `UNION SELECT` dump 全表 |
| **D**enial of Service 拒绝服务 | 「我把你搞挂了」 | **可用性**（Availability） | `/api/agent` 无速率限制 + Flask 单进程 → 高频打挂 |
| **E**levation of Privilege 提权 | 「我拿到了本不属于我的权限」 | **授权**（Authorization） | `/orders` 无行级授权，alice 登录后 `?user=admin` 横向越权 |

**直觉口诀**：**S** 是「**假冒身份**」、**T** 是「**改数据**」、**R** 是「**赖账**」、**I** 是「**泄密**」、**D** 是「**搞挂**」、**E** 是「**提权**」。前三对（S/E）是身份相关，中间（T/I）是数据相关，**D** 单独是可用性，**R** 单独是审计。

---

## 3. 弯路：做 STRIDE 时最常走的岔路

| 弯路 | 错在哪 | 正解 |
|---|---|---|
| 「STRIDE 就是 6 个词，我脑子里过一遍就行」 | 脑内过 = 一定会漏；STRIDE 的价值在**逐对象、逐类、落到代码位置** | 对**每个组件/数据流**建表，6 类**逐一**写一条威胁 + **挂 `app.py` 具体行/路由** |
| 「威胁建模 = 列已知漏洞」 | 那叫漏洞扫描，不是建模。建模是**对系统结构与数据流**推威胁 | 先画组件/数据流（如 `/login → session`、`/orders → app.db`），再对每条过 STRIDE |
| 「只覆盖 4 类就够了，R/D 罕见」 | 本课校准语料的 medium 档就是**漏 R/D**被判扣分；R（审计缺失）和 D（无速率限制）在你 `seed/app.py` 里**真实存在** | **六类必须穷举**，每类至少一条真实威胁；漏类 = STRIDE 建模不合格 |
| 「威胁描述泛泛即可」 | 「系统可能不安全」不是威胁 | 威胁要**具体**：`/orders?user=` 拼接 → 攻击者 `'; UPDATE --` 篡改订单（**T**） |

---

## 4. 形式化：STRIDE 的「穷举性」从哪来

STRIDE 之所以能保证「不漏类」，是因为它**对齐了安全属性的完整集合**：

- 信息安全的**三大目标**：C（机密性）、I（完整性）、A（可用性）—— STRIDE 里的 **I / T / D**。
- 加上**三个「是谁干的」相关属性**：Authentication（认证）、Authorization（授权）、Accountability/Non-repudiation（不可抵赖）—— STRIDE 里的 **S / E / R**。

这 6 个属性是**信息安全目标的正交分解**，所以基于它们的 STRIDE 是（近似）穷举的。**应用方式**（这就是 M0 的 `stride.md` 要你做的）：

> 对系统里每个「**组件**」（端点、数据存储、外部依赖）或「**数据流**」（用户→`/login`、`/orders`→`app.db`），逐一过 S/T/R/I/D/E 六类，**每类写至少一条真实威胁**，并标注它**对应代码的哪一行/哪一个路由**。

---

## 5. 代码实例：对 `seed/app.py` 做一次 STRIDE（M0 的真实任务）

以 `/orders` 端点（`app.py:67-74`）为例，这是 M0 `stride.md` 里应该出现的**真实建模**：

| 对象 | STRIDE | 威胁（挂代码位置） | 破坏属性 |
|---|---|---|---|
| `/orders` | **T** 篡改 | `q=f"...WHERE user='{user}'"` 拼接 → `'; UPDATE orders --` 改订单 | 完整性 |
| `/orders` | **E** 提权 | 无行级授权，`?user=admin` 越权读他人订单 | 授权 |
| `/orders` | **I** 信息泄露 | `UNION SELECT sql,name FROM sqlite_master --` dump 库结构 | 机密性 |
| `AUDIT` 日志 | **R** 否认 | `AUDIT.info` 字段不全（无 user/tool 完整链路）→ 操作可抵赖 | 不可抵赖 |
| `/api/agent` | **D** 拒绝服务 | 无速率限制 + Flask 单进程 → 高频请求耗尽资源 | 可用性 |
| `/login` | **S** 假冒 | `USERS={admin:admin123}` 明文弱口令可爆破 | 认证 |

**这就是 lab00 任务 C 要你产出的东西**——不是空谈，是逐端点、逐类、挂行号。你的 `docs/m0/stride.md` 越像这张表，STRIDE 这关分数越高。

---

## 6. 常见误区

| 误区 | 真相 |
|---|---|
| 「STRIDE 只适用于 Web」 | 它对**任何有组件与数据流的系统**都适用（API、智能体、CI/CD、甚至 RAG 管线） |
| 「STRIDE 列完就完事」 | 列威胁只是第一步；每条要配 **CVSS 评分 + 责任里程碑**（M0 的 `risk-register.md`） |
| 「STRIDE = OWASP Top 10」 | OWASP Top 10 是**统计出来的常见漏洞**；STRIDE 是**结构化穷举框架**——前者告诉你「大家常犯什么」，后者逼你「对自己的系统不漏类」 |
| 「威胁要越多越好」 | 关键是**穷举六类 + 每条真实挂代码**，不是数量；泛泛堆砌会被判「精度一般」 |

---

## 7. 延伸

- **前置**：本篇是 M0 的地基——做完 `docs/m0/stride.md` 你就掌握 STRIDE。
- **进阶框架**：STRIDE 是「**我能想到哪些坏事**」；想系统化「**攻击者实际会怎么打**」可进一步了解 **Cyber Kill Chain** 与 **MITRE ATT&CK**（U2/U3 会用到）。
- **AI 扩展**：到了 U6，STRIDE 同样适用于 LLM 智能体——把 `/api/agent` 当一个组件，**T**（提示词注入篡改智能体行为）、**I**（RAG 投毒泄露训练/检索数据）、**E**（提示词注入越权调用高危工具）都能套进去。STRIDE 是**可迁移**的思维工具。
- **自测要点**：
  1. 默写 STRIDE 6 类 × 对应安全属性的映射。
  2. 对 `/login` 端点，6 类各写出一条挂代码的真实威胁。
  3. 解释为什么「漏掉 R 和 D」在 M0 会被扣分（提示：穷举性）。

---

> **本文件由 [teachme](https://github.com/c4pr1c3/teachme) 的「七要素」教学法生成**，是 U0 课件 + lab00 的助学补充——把 STRIDE 讲成可上手的思维工具。想为别的主题产同款材料，调 `/teachme`。
