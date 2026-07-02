# 实验 06：AI 赋能与对抗 · 综合实践项目（capstone）里程碑 M6

> 本实验 = 渐进式作品的 **M6**（核心里程碑）。需先完成 M0-M5（一个已加固、带日志/蜜罐的靶场 Web 应用）。

## 1. 实验目标

- **能力交付**（簇 ⑥ · L2 双向）：
  1. <span style="color:#1a73e8">**赋能**</span>：给应用集成一个 LLM 功能 + 一个 AI 检测组件，并度量效能。
  2. <span style="color:#d93025">**对抗**</span>：对该 AI 功能做攻击概念验证（PoC），并加固。
- 这是整门课**唯一同时命中两大 AI 维度**的里程碑。

## 2. 环境准备

- 你的 M5 末仓库（已含鉴权、IDS/日志、蜜罐）；起点可 fork [`capstone/seed/`](../../../capstone/seed/) 的 `app.py`（已含 `/api/agent` 端点 + 工具白名单护栏钩子）。
- 一个 LLM（外部 API 或本地推理）；Python + `scikit-learn`（AI 检测组件）。
- ⚠️ 所有攻击实验**仅在自己的靶场、授权环境**内进行；课程不教授编写恶意代码。

## 3. 任务清单

### 任务 A — 赋能·集成 LLM 功能

给应用加一个带**工具/数据访问**的 AI 能力（任选其一）：智能客服/FAQ（RAG）、工单摘要、自然语言查日志。

```{.python .numberLines}
@app.post("/api/agent")
def agent(q: str):
    docs = rag.retrieve(q)              # 对抗侧会投毒这里
    ans  = llm.chat(q, context=docs, tools=[get_order])
    audit.log(user=current_user, q=q, ans=ans)
    return ans
```

### 任务 B — 赋能·集成 AI 检测组件

用 ML-IDS / UEBA 提升防御（呼应课件 03）：对登录/请求行为用 Isolation Forest 打风险分，高分触发告警。

```{.python .numberLines}
from sklearn.ensemble import IsolationForest
# 特征：[小时, 是否国内, 频率, 失败次数]
model = IsolationForest(contamination=0.02).fit(X_normal)
risk  = -model.score_samples(X_live)   # 越大越异常
```

### 任务 C — 对抗·攻击 AI 功能（红队，≥2 类概念验证）

- **间接提示注入**：在智能体（Agent）会读的文档/评论里藏指令，诱导调用受限工具或泄露数据。
- **RAG 投毒 / 向量注入**：往知识库塞恶意文档，误导输出。
- **越狱 / 工具滥用**：绕过护栏；把只读工具当外传通道。
- 记录「劫持/误导是否成功」。

### 任务 D — 对抗·加固（防御证据）

- 工具**白名单 + 人在回路**（高危动作须人工确认）。
- 不可信内容打标，限制其对指令的影响；输出/动作护栏。
- 全链路审计。
- **度量**：加固前后**劫持成功率下降**（给数字）。

```{.python .numberLines}
ALLOW = {"search", "get_order"}; DENY = {"email", "http_post", "rm"}
def guard(a):
    if a.tool in DENY:      return block(a)
    if a.tool not in ALLOW: return ask_human(a)   # 人在回路
    return run(a)
```

### AI 助教适配注意事项

本里程碑是 **AI 双向核心**，由 AI 助教（`ns4ai-review`）按 §4 量规重点审 AI 赋能与对抗双向。提交时注意：

- **常见扣分**：只有 LLM 无检测组件（完成度「仅其一」→不合格档）、无度量数字（仅「能跑」）、概念验证不足 2 类、无白名单/人在回路、未开 MR 或分支命名不符规范。
- **授权红线**：`exfil`/`read_file` 等工具不得有真实副作用（仅返回说明串）；所有攻击仅在自己靶场。
- **AI 双向（本里程碑核心）**：接入的 LLM **必须国产**（`deepseek-v4-flash`/Qwen/GLM/Kimi）；本里程碑即「用 AI（赋能）→ 攻 AI（注入/滥用）→ 防 AI（护栏+检测）」的闭环，三面均须有证据。
- **自评矩阵**：在 `report.md` 对照簇⑥·L1/L2（双向），每项附证据，「无虚点亮」。

## 4. 交付与量规（绑定簇 ⑥ · L2）

| 维度 | 优秀 | 合格 | 不合格 |
| :-: | :- | :- | :- |
| 赋能完整度 | LLM 功能 + AI 检测均集成 | 仅其一 | 无 |
| 度量严谨 | 有数据对比 + 局限分析 | 有基本度量 | 仅「能跑」 |
| 对抗深度 | ≥2 类概念验证 + 加固证据 | 1 类概念验证 | 无攻击 |
| 加固工程化 | 白名单/HITL/审计齐备 | 部分护栏 | 无加固 |

**交付物**：代码（分支 `milestone/m6` + MR）、攻击概念验证、度量报告（赋能 Precision/Recall + 局限；对抗加固前后对比）、能力自评。

## 5. 能力自评

- 簇 ⑥·L1：能区分赋能 vs 作为对象 ✅
- 簇 ⑥·L2（对象）：完成注入/投毒概念验证 + 加固 ☐
- 簇 ⑥·L2（赋能）：集成 AI 检测组件 + 度量 ☐
- 进阶（L3，U7）：在红蓝对抗中综合评估 AI 局限 ☐

### 进阶对标（AI 红队基准与自主 agent）

- 用 [PentestGPT](https://github.com/GreyDGL/PentestGPT) / 腾讯云 TCH / [METATRON](https://github.com/sooryathejas/METATRON) 对你的应用做一次「AI 自主渗透」，与人工 M3 结果对比（命中/误报/盲区）
- 把对抗概念验证套到评估基准思路（[ExploitGym](https://arxiv.org/abs/2605.11086) / [XBOW benchmarks](https://github.com/xbow-engineering/validation-benchmarks)）——度量「AI 攻击你的 AI 防御」的攻击成功率（ASR）
- 方法论参照 [OWASP GenAI Red Teaming Guide](https://github.com/requie/AI-Red-Teaming-Guide)

> 参考：[`capstone/m6-ai.md`](../../../capstone/m6-ai.md)、课件 `01-overview` / `02-ai-as-target` / `03-ai-empower`、`study/unit06-guide.md`、[`study/ai-pentest-resources.md`](../../../study/ai-pentest-resources.md)。
