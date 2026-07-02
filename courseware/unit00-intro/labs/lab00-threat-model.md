# 实验 00：立项与威胁建模

> 本实验即综合实践项目（capstone）**M0**。你将从零立项，并对派生的种子工程完成第一份**威胁建模 + 风险登记表**。这是整学期工程的「地基」，后续 M1-M7 都在它之上演进。

## 1. 实验目标

- **能力交付（绑定簇①·L2）**:
  1. 能够派生种子工程并建立可演进的项目仓库骨架。
  2. 能够对一个具体 Web 应用做**资产清单 + CIA 标注**。
  3. 能够用 **STRIDE** 对系统威胁进行穷举式建模。
  4. 能够用 **CVSS 3.1** 对识别出的风险打分，并产出一份**风险登记表**。

> 完成本实验后，在里程碑报告中对照能力框架自评：点亮 **簇①·L1（认知）+ 簇①·L2（实践）**。

## 2. 环境准备

- **本地**: Windows 10/11（推荐 WSL 2 Ubuntu 22.04）或 macOS，已安装 Git、Python 3.10+。
- **仓库**: 课程 GitLab。每个学生在课程 GitLab Group 下派生 [`capstone/seed/`](../../../capstone/seed/README.md) 为自己的私有仓库（命名建议 `cuc-ns-<学号>`）。
- **Git 规范**（重要）：本学期用「**分支 + MR**」标记里程碑，**不打 tag**。M0 流程 = 从 `main` 切 `milestone/m0` → 完成下述产物 → push → 开 MR（源=`milestone/m0`、目标=`main`）→ @ 助教 → 保持 Open。完整步骤见 [Git 操作指南](git-guide.md)；一键开分支：`bash scripts/new-milestone.sh 0`。
- **种子工程最小可运行**:

  ```bash
  git clone <你的 GitLab 仓库地址>
  cd cuc-ns-<学号>
  python3 -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  python app.py          # 监听 127.0.0.1:5000
  ```

- **学术诚信**: 所有攻击实验**仅在你派生的靶场、授权环境**内进行；课程不教授编写恶意代码。本实验只做**建模与评分**，不写任何攻击载荷（payload）（攻击在 M3）。

> 种子应用 `app.py` 故意预留了攻击面（弱口令、SQL 拼接、智能体（Agent）端点），它们就是本次威胁建模的**真实素材**。

## 3. 任务清单

### 任务 A: 技术选型 + 仓库骨架

1. **派生种子工程**到课程 GitLab，克隆到本地，确认 `python app.py` 可启动并访问 `/login`。
2. 在仓库根创建 `docs/` 目录，本实验的所有产物**提交到 `docs/m0/`** 下。
3. 在 `docs/m0/tech-stack.md` 记录技术选型：
   - 运行时（Python 版本）、Web 框架（Flask）、数据库（SQLite）、部署目标（本机/容器）。
   - 你计划在 M6 接入的 LLM 提供方与接入方式（API/本地推理）——先写意向，后续可改。
4. 建立**里程碑节奏**：在仓库根 `README.md` 追加一节「里程碑进度」，列出 M0-M7 及计划截止日期。

> 交付物：可运行的仓库 + `docs/m0/tech-stack.md` + 更新后的 `README.md`。

### 任务 B: 资产清单 + CIA 标注

阅读 `app.py` 全文，识别系统中的**信息资产**，为每个资产标注其最受关注的 CIA 属性。

在 `docs/m0/assets.md` 产出下表（至少覆盖以下资产，可补充）：

| 资产 | 类型 | 位置 | C | I | A | 说明（为何该属性最重要） |
| :- | :- | :- | :-: | :-: | :-: | :- |
| 用户口令（明文存储） | 凭据 | `USERS` 字典 | **H** | M | L | 泄露即等于账户沦陷 → 机密性优先 |
| 会话 cookie | 状态 | `session` | H | H | M | 劫持 = 身份冒充 |
| 订单数据 | 业务数据 | `orders` 表 | M | H | M | 篡改/越权读取 |
| 应用密钥 `secret_key` | 配置 | `app.secret_key` | **H** | H | L | 泄露可伪造会话 |
| 智能体查询输入 | 不可信输入 | `/api/agent` body | M | H | M | 注入入口 |
| 审计日志 | 取证依据 | `AUDIT` | L | **H** | M | 被篡改则无法追责 |

> 提示：结合种子代码中的 `USERS`、`session`、`orders`、`secret_key`、`/api/agent`、`AUDIT` 逐一对照。

### 任务 C: STRIDE 威胁建模

对种子工程的关键**组件/数据流**逐一过 STRIDE 六类，**不漏威胁**。建议建模对象至少包含：

- `/login` 端点（口令校验、会话签发）
- `/orders` 端点（带 `user` 参数的 SQL 拼接）
- `/api/agent` 端点（LLM + 工具调用）
- `call_tool` 护栏（白名单/黑名单/人在回路）
- SQLite 数据文件 `app.db`

在 `docs/m0/stride.md` 产出下表（每个对象至少识别 2-3 条真实威胁）：

| 对象 | STRIDE 类别 | 威胁描述 | 触发条件/代码位置 | 对应破坏的属性 |
| :- | :- | :- | :- | :- |
| `/login` | **S** 假冒 | 弱口令（admin/admin123）可被字典爆破 | `USERS` 明文弱口令 | 认证 |
| `/login` | **I** 信息泄露 | 登录失败/成功响应可枚举有效用户名 | `login.fail` vs `login.success` | 机密性 |
| `/orders` | **T** 篡改 | `user` 参数字符串拼接 → SQL 注入可改/删数据 | `q = f"... WHERE user = '{user}'"` | 完整性 |
| `/orders` | **E** 提权 | 注入可读取/篡改他人订单，越权访问 | 同上，无行级授权 | 授权 |
| `/api/agent` | **T** 篡改 | 间接提示词注入让 LLM 调用非白名单工具 | `body.get("tool")` 直传 | 完整性/授权 |
| `call_tool` | **R** 否认 | 审计仅记 `info/warning`，缺用户/tool 完整链路 | `AUDIT.info` 字段不全 | 不可抵赖 |
| `app.db` | **I** 信息泄露 | SQLite 文件可直接下载/读取 | 部署时未隔离文件 | 机密性 |

> 严格要求：威胁必须**对应到 `app.py` 的具体代码或部署事实**，禁止泛泛而谈。每条至少给出「代码位置」或「触发条件」。

### 任务 D: 风险登记表（含 CVSS 评分）

为任务 C 识别出的**高优先级威胁**（建议至少 5 条）打 CVSS 3.1 Base 分，产出 `docs/m0/risk-register.md`：

| ID | 威胁（来自任务 C） | CVSS 向量 | Base 分 | 等级 | 缓解措施（留给后续 M） | 责任里程碑 |
| :- | :- | :- | :-: | :-: | :- | :-: |
| R1 | 弱口令爆破 `/login` | `AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` | 9.8 | 严重 | 口令哈希 + 失败计数 + 锁定 | M1 |
| R2 | `/orders` SQL 注入 | `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H` | 8.8 | 高 | 参数化查询 + 输入校验 | M3 |
| R3 | 智能体间接注入调用高危工具 | `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N` | 8.1 | 高 | 强化白名单 + 人在回路 + 输出过滤 | M6 |
| R4 | 会话密钥泄露致伪造 | `AV:N/AC:H/PR:N/UI:N/S:C/C:H/I:H/A:N` | 8.6 | 高 | 安全随机密钥 + 密钥轮换 | M1 |
| R5 | 审计日志可被篡改 | `AV:L/AC:L/PR:H/UI:N/S:U/C:N/I:H/A:N` | 4.5 | 中 | 集中日志 + 只读追加 + 时间戳签名 | M5 |

> 评分工具：[NVD CVSS 3.1 计算器](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator)。等级划分：0.1-3.9 低 / 4.0-6.9 中 / 7.0-8.9 高 / 9.0-10.0 严重。
> CVSS 完整推导见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x02.md`。

### AI 助教适配注意事项

本里程碑由 AI 助教（`ns4ai-review`）按 §4 量规做确定性证据采集 + LLM 档位裁定。提交时注意：

- **常见扣分**：STRIDE 漏类（必须六类逐项过）、CVSS 向量与分数不自洽、威胁不挂 `app.py` 代码位置（泛泛而谈）、CIA 一刀切全标 C+I+A、无 `report.md` 自评矩阵。
- **授权红线**：仅对自己派生的 `app.py` 建模；不得对真实/第三方系统做任何探测。
- **AI 双向**：鼓励用**国产大模型**（如 `deepseek-v4-flash`）辅助起草建模/资产识别，但须在 `report.md` 注明用了哪些 AI 辅助 + 人工复核了什么；本课程禁止选用国外大模型（GPT/Claude/Gemini）。
- **自评矩阵**：在 `report.md` 逐项对照簇①·L1/L2，每项附证据路径，「无虚点亮」。

## 4. 交付与量规

在仓库 `docs/m0/` 下提交以下文件——在 `milestone/m0` 分支上完成、push、开 MR @ 助教（详见 [Git 操作指南](git-guide.md)）：

```
docs/m0/
├── tech-stack.md        # 任务 A：技术选型 + 里程碑节奏
├── assets.md            # 任务 B：资产清单 + CIA 标注
├── stride.md            # 任务 C：STRIDE 威胁建模
└── risk-register.md     # 任务 D：风险登记表（含 CVSS）
```

里程碑报告（`docs/m0/report.md`）需包含：做了什么 / 点亮哪些能力簇×级 / 踩到什么坑 / 对后续 M 的建议。

**评分量规（绑定簇①·L2，满分 100）**:

| 维度 | 权重 | 优秀 (90+) | 合格 (60-80) | 不合格 (<60) |
| :-: | :-: | :- | :- | :- |
| **资产清单** | 20 | 资产识别完整，CIA 标注有依据 | 覆盖主要资产 | 关键资产缺失 |
| **STRIDE 建模** | 30 | 六类穷举，每条挂代码位置 | 过多数对象 | 仅泛泛列举 |
| **CVSS 评分** | 30 | 向量与分数自洽，等级合理 | 能打分但依据弱 | 分数随意 |
| **工程规范** | 20 | 仓库可运行 + 分支/MR 规范 + 报告完整 | 基本规范 | 无法运行/未开 MR |

## 5. 能力自评

完成本实验后，在 `docs/m0/report.md` 末尾填写能力自评（对照 [`capability-framework.md`](../../../capability-framework.md)）：

| 簇 × 级 | 能力描述 | 是否点亮 | 证据 |
| :-: | :- | :-: | :- |
| ①·L1 | 复述 CIA/STRIDE/CVSS，识别资产与威胁 | ☐ | 课堂快问快答 + 本实验资产/威胁识别 |
| ①·L2 | 对一个系统做威胁建模 + CVSS 评分 | ☐ | M0 的 `stride.md` + `risk-register.md` |

> 自评须与作品一致；M7 综合收口时会回看这份自评矩阵。下一单元 U1（M1 安全基线）将把这里识别出的鉴权/会话/口令风险**落到代码**。
