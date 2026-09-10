# Git 操作指南与规范（本学期综合实践项目专用）

> 这是《网络安全（AI 时代版）》渐进式作品（综合实践项目 M0-M7）的**唯一** Git 提交规范。
> 适用对象：所有学生，**尤其是自认为 Git 基础薄弱的同学**——按本指南照做即可，不需要额外看其它教程。
> 配套：[综合实践项目总览](../../../capstone/overview.md) · [种子工程](../../../capstone/seed/README.md) · [实验 00 / M0](lab00-threat-model.md) · [CI 指南](ci-guide.md)

---

## 1. 为什么本学期要单独讲 Git

如果你上学年上过 Linux 课，会记得它教的 Git 流程：**每个单元从 `main` 切一个分支、建同名目录、开一个 MR、保持 `Open` 不合并**。那套流程对「每单元独立」的作业是对的。

**但本学期不一样**：整学期只做一个工程——一个「含 AI 能力的靶场 Web 应用」，按里程碑 M0→M7 **渐进迭代**。也就是说：

> **M2 的代码踩在 M1 上，M1 踩在 M0 上……同一个仓库、同一套代码，一路长成一个完整系统。**

这条「累积」性质，直接决定了 Git 的用法必须改。具体改在哪，见 [§9 和 Linux 课的差异](#9-和-linux-课的-git-流程有何不同)。先记住下面三条铁律即可。

---

## 2. 三条铁律（先记住这三条）

| # | 铁律 | 一句话 |
| :-: | :- | :- |
| ① | **用分支标记里程碑** | 完成一个里程碑 = 开一个名为 `milestone/m{n}` 的分支；**不再打 tag**。 |
| ② | **用 MR 叫助教来批改** | 分支推上去后，开一个 Merge Request 并 **@助教**（把助教勾选为 reviewer）。**只 push 代码 ≠ 交卷**，开了 MR 且 @ 了助教才算交卷。 |
| ③ | **不合并不关闭，学期末才收尾** | 每个 MR **保持 `Open`**：不要点 Merge、不要 Close。每个 MR 只含**一个里程碑**的内容。学期全部结束、所有 M 评审完成后，再把最终的 `milestone/m7` 合回 `main`。 |

> 助教（含 AI 助教 `ns4ai-review`）**只看你 MR 里的 changes** 来批改。所以 MR 里有什么、范围对不对，直接决定你的分数。

---

## 3. 分支长什么样（拓扑图）

本学期的里程碑分支**首尾相接、层层叠加**，像一串糖葫芦：

```
main ────────────────────────────────────── (冻结到学期末，别碰它)
  │
  └─ milestone/m0     ← MR m0  目标: main
      └─ milestone/m1   ← MR m1  目标: milestone/m0
          └─ milestone/m2   ← MR m2  目标: milestone/m1
              └─ milestone/m3  …
                  └─ … 直至 milestone/m7
```

**关键直觉**：

- **`main` 是博物馆**：学期内冻结，谁都不许往里直接提交或合并。它是你派生种子时的初始状态。
- **每个里程碑是一条「叠在上一个之上」的分支**：`milestone/m2` 里**包含** M0+M1+M2 的全部代码（所以助教能直接运行你 M2 时的完整系统），但它**相对 `milestone/m1` 只多了 M2 那一截**（所以助教看到的 MR diff 干净，只有 M2 的增量）。
- **为什么必须叠，而不能每次都从 main 切？** 因为代码是累积的。如果 `milestone/m2` 从冻结的 `main` 切，里面就没有 M1 的代码，系统根本跑不起来。

### 3.1 命名规范

- 里程碑分支固定叫 **`milestone/m0`、`milestone/m1`、…、`milestone/m7`**——与里程碑编号一一对应，**不要自创名字**。
- `milestone/` 这个前缀是**命名空间**：GitLab 网页上会自动把它们折叠成一组，你和助教一眼就能看清进度。
- **不要打 tag**（`git tag`）：本学期分支就是标记，tag 是多余的，且会和分支名撞车。

---

## 4. 每个里程碑的标准操作（复制即用）

### 4.1 第一次：开 M0（从 main 切）

```bash
# ① 确认在 main，且是最新的种子
git switch main
git pull origin main

# ② 创建 M0 分支
git switch -c milestone/m0

# ③ 做 M0 的实验（见 lab00），产物放进 docs/m0/
#    例如：docs/m0/tech-stack.md、assets.md、stride.md、risk-register.md、report.md
#    （每个里程碑必备哪些目录和文件，见 §6 的逐里程碑规划）
#    小步、多次、写人话 commit：
git add docs/m0/
git commit -m "feat(m0): 资产清单 + CIA 标注"
# ...继续边做边 commit...

# ④ 推送 M0 分支
git push -u origin milestone/m0
```

然后去 GitLab 网页开 MR（见 [§5](#5-在-gitlab-上开-mr--叫助教)）：**源 = `milestone/m0`，目标 = `main`**。

### 4.2 之后每一次：开 M{n}（n ≥ 1，从上一里程碑切）

> ⚠️ **最容易踩的坑**：M2 要从 **`milestone/m1`** 切，**不是从 main 切**。回到上一里程碑分支，再切新的。

```bash
# ① 回到「上一个里程碑」的分支（不是 main！）
git switch milestone/m1
git pull origin milestone/m1

# ② 从这里切出新的里程碑分支
git switch -c milestone/m2

# ③ 做 M2 的实验，产物放进 docs/m2/（逐里程碑目录规划见 §6.2）
git add docs/m2/
git commit -m "feat(m2): 暴露面清单 + 参数化侦察脚本"
# ...边做边 commit...

# ④ 推送
git push -u origin milestone/m2
```

然后开 MR：**源 = `milestone/m2`，目标 = `milestone/m1`**（目标务必选上一里程碑分支，不要选 main）。

> 把上面这段里的 `m1`/`m2` 换成你当前的里程碑编号即可，每个里程碑重复一次。

### 4.3 一句话总结例行流程

```
回到上一里程碑分支 → 切新分支 → 做实验写报告 → push → 开 MR（目标=上一里程碑分支）→ @助教 → 保持 open
```

---

## 5. 在 GitLab 上开 MR + 叫助教

1. 推送分支后，打开课程 GitLab 上**你自己的仓库**，左侧 **Merge requests → New merge request**。
2. **选源分支**：`milestone/m{n}`。
3. **选目标分支**（关键！）：
   - M0 → 目标选 `main`；
   - M1..M7 → 目标选 **`milestone/m{n-1}`**（上一个里程碑分支）。GitLab 默认会填 `main`，**你必须手动改掉**。
4. 标题写成：`M{n} <里程碑主题> 评审`，例如 `M2 自侦察 评审`。
5. **Reviewer / Assignee 勾选助教**——这一步等于「发消息提醒助教来批改」，没勾 = 助教不知道你交了。
6. **不要点 Merge**、**不要点 Close**。开好就放着，保持 `Open` 状态。
7. 开完后，**在网页上把 MR 的 Changes 翻一遍**：报告里的图片能不能显示、文件路径对不对。**你在 MR 里看到什么样，助教看到的就是什么样。**

### 5.1 助教给了修改意见怎么办？

**不用关 MR、不用重开、不用新切分支**。直接在**同一个** `milestone/m{n}` 分支上继续改、继续 commit、继续 `git push`，MR 会自动更新成最新内容，然后**在 MR 评论区 @ 助教**说「已修改，请重新批改」即可。整个学期里，一个里程碑从头到尾只用**一个分支 + 一个 MR**。

---

## 6. 仓库目录结构与文件命名规划（逐里程碑）

> 本节回答「每个分支里建哪些目录、文件叫什么」。条目分三层：**必备**（固定锚点，助教按它找证据，随意改名 ≈ 让助教找不到）、**建议**（验证过的好习惯）、**自由**（随你发挥，见 [§6.3](#63-自由发挥空间)）。

### 6.1 全学期不变的仓库骨架

以完成全部里程碑后的形态为准，一个规范的作业仓库长这样：

```
├── app.py  requirements.txt  app.db   # 种子工程：原位演进（M1/M4 等直接改它），不搬家、不复制副本
├── README.md          # 门面：项目简介 + 里程碑进度表（每完成一个 M 回填一行）
├── demo.sh            # 根目录一键自检：随里程碑滚动扩充，CI 就调它（见 ci-guide.md）
├── .gitlab-ci.yml     # CI 配置，M0 就建好（配置方法见 ci-guide.md）
├── .gitignore         # 至少忽略：.venv/、__pycache__/、app.db、实验产物目录
├── docs/
│   ├── m0/            # 每个里程碑一个目录，report.md 必在其中
│   ├── m1/            #   截图统一放 docs/m{n}/screenshots/，报告里用相对路径引用
│   └── … 直至 m7/
├── scripts/           # 工具脚本（可自行增加）
└── tests/             # 回归测试（建议从 M1 起建立）
```

三条布局铁律：

1. **代码原位演进**：`app.py` 等种子文件就地修改，不要复制出 `app_m1.py`、`app_v2.py`——版本由分支表达，不由文件名表达。
2. **文档进 `docs/m{n}/`**：本里程碑的一切文字交付（报告、清单、手册）放这里；`report.md` 是入口，其它文件都从 `report.md` 里用相对链接指过去。
3. **可执行证据跟着产物走**：`demo.sh`、PoC 脚本、测试，与它们所验证的里程碑放在同一处，并串进根目录的滚动 `demo.sh`。

### 6.2 逐里程碑规划

**M0 · 立项与威胁建模（纯文档）**

- 必备（`docs/m0/` 下）：`tech-stack.md`（技术选型 + M6 拟接入的国产 LLM）、`assets.md`（资产清单 + CIA 标注）、`stride.md`（STRIDE 六类逐项，每条挂 `app.py` 代码位置）、`risk-register.md`（风险登记 + 完整 CVSS 3.1 向量）、`report.md`（里程碑报告 + 能力自评矩阵）
- 建议：`README.md` 加「里程碑进度」表并回填 M0 行；建好 `.gitlab-ci.yml` 与根 `demo.sh`（M0 的自检可以是「必备文档是否齐全」这类结构校验）
- 自由：STRIDE 表格模板、风险登记表字段、自评矩阵样式

**M1 · 安全基线（改代码为主）**

- 必备：`docs/m1/report.md`——含 RBAC 设计、「种子弱实现 vs 新实现」加固对照表、网络基线说明、自评
- 代码（以原位修改 `app.py` 为主，无强制文件名）：口令哈希、会话加固、失败锁定、RBAC 装饰器
- 建议：`docs/m1/demo.sh` 加固回归自检；测试文件（`tests/` 或 `docs/m1/tests*.py`），并把回归接进根 `demo.sh`
- 自由：测试写法（pytest / 裸 assert 均可）、加固项的取舍与实施顺序

**M2 · 自侦察**

- 必备：暴露面清单（如 `exposure-inventory.md`，含风险等级 + 处置建议）、可复用侦察脚本（`recon.sh` / `recon.py` / `scanner.py` 风格，参数化目标 + 结构化输出）、asciinema 录屏（`.cast` 后缀，如 `lab02.cast`）、`report.md`（含授权声明：实验仅限 `127.0.0.1`）
- 布局说明：产物可以放 `docs/m2/`，也可以放 `lab02/`——两种布局助教都认；但**同一个里程碑内请统一用一处**，并在 `report.md` 里逐一链接
- 建议：nmap 结构化产物落盘（如 `surfaces.json`）+ 解析脚本（如 `parse_nmap.py`）；`docs/m2/demo.sh` 做产物结构自检
- 自由：脚本语言、结构化输出字段、清单的列设计

**M3 · Web 漏洞挖掘与利用**

- 必备（`docs/m3/` 下）：四类概念验证（PoC），文件名含 `poc`——`sqli-poc.py`、`xss-poc.py`、`upload-poc.py`、`csrf-poc.py`（扩展名不限）；`report.md`（每类写清原理 + 触发条件 + 影响 + 复现步骤）
- 红线提醒：PoC 与报告里的目标 URL 只允许 `127.0.0.1` / `localhost`
- 建议：`docs/m3/demo.sh` 一键复现四类 PoC；CSRF 的诱导弹页（如 `evil-csrf.html`）
- 自由：PoC 形态（python 脚本 / curl 集合均可）、攻击载荷（payload）设计

**M4 · 加固与边界防护**

- 必备：IDS 规则文件（文件名含 `ids` / `suricata`，或 `.rules` 后缀，如 `local.rules`）、WAF 实现（如根目录 `waf.py` 或 `waf/` 目录）、`docs/m4/report.md`——含规则集说明、加固 diff、命中/误报度量数字（TP/FP/precision/recall）、自评
- 代码：运行环境加固（如 `debug=False`、指纹隐藏），原位改 `app.py`
- 建议：规则校验与度量脚本（如 `validate_rules.py`、`fp-measure.py`）；`tests/` 里加「加固后回归」（M3 的 PoC 现在应被拦下）
- 自由：规则条数与覆盖面、WAF 的实现位置（中间件 / 装饰器均可）

**M5 · 日志 · 取证 · 蜜罐**

- 必备：`docs/m5/playbook.md`（取证应对手册，固定文件名）、蜜罐（如根目录 `honeypot.py`，绑定 `127.0.0.1` 并写清隔离说明）、日志管线说明（如 `log-pipeline.md`）、攻击链复盘（`attack-replay.md` 或 `timeline.md`）、`docs/m5/report.md`
- 建议：日志采集脚本（如 `collect.sh`）；日志防篡改用 `hashlib`/`hmac` 实现并在报告里说明（呼应 M0 风险登记里的对应条目）
- 自由：日志格式与字段设计、蜜罐交互深度、威胁情报指标（IoC）清单格式

**M6 · AI 赋能与对抗（学期核心）**

- 必备（文件名即锚点）：LLM 功能（`/api/agent` 端点，或 `fake_llm.py` / `agent.py` / `llm.py`）、AI 检测组件 `detector.py`、对抗 PoC `attack_poc.py`（≥ 2 类：间接提示注入 / RAG 投毒 / 越狱 / 工具滥用）、护栏 `guardrail.py`（白名单 + 人在回路）、`report.md`（含 ASR 加固前后对比、Precision/Recall 度量）——**LLM 功能与 AI 检测组件两者都要有，缺一不可**
- 硬性约束：接入的 LLM 只允许国产模型（DeepSeek / Qwen / GLM / Kimi）；演示外泄的工具不得有真实文件写副作用
- 建议：产物放 `lab06/` 或 `docs/m6/` 均可（同 M2 的布局规则）；评估脚本（如 `drift_eval.py`）；全链路审计日志
- 自由：护栏策略、检测算法（规则 / z-score / IsolationForest 均可）、PoC 场景设计

**M7 · 红蓝对抗 + 复盘 + 自评**

- 必备（`docs/m7/` 下）：`redblue-record.md`（场景 + 红队攻击链 + 蓝队复盘 + 纵深度量）、`forensics-report.md`（时间线 + IoC）、能力自评矩阵（如 `self-matrix.md` / `capability-matrix.md`，每项挂 M0-M6 的证据相对路径）、`report.md`（含 AI 综合评估与其局限）、动态证据（录屏或证据包）
- 建议：复盘脚本（如 `red_team.py`、`timeline.py`）；`README.md` 进度表补齐全部 8 行
- 自由：演练场景与红蓝剧本、矩阵呈现形式

### 6.3 自由发挥空间

| 类别 | 固定别动 | 随你发挥 |
| :- | :- | :- |
| 分支 | `milestone/m{n}` | 临时开发分支随便建，只要别当评审分支 push |
| 目录 | `docs/m{n}/`、`docs/m{n}/screenshots/`（建议） | 额外建 `notes/`、`assets/` 等随意 |
| 文件名 | §6.2 标「必备」的锚点文件 | 辅助脚本、笔记、中间产物命名随意（建议英文小写 + 连字符，如 `parse-nmap-draft.py`） |
| 代码布局 | 同一里程碑内统一放一处 | 放 `docs/m{n}/` 还是 `labNN/` 由你定，二选一 |
| commit | 小步、多次、说人话；分摊在整个里程碑周期里提交，别拖到最后一天一次堆完 | message 中英文随意，`feat`/`fix`/`docs` 前缀风格自选 |
| README | 要有里程碑进度表 | 排版、徽章、配图随意 |

**一条总原则**：凡是你自由命名、自由放置的产物，都要能在 `report.md` 里被一个相对链接点到。助教（人和 AI）找证据的顺序是「固定锚点 → `report.md` 里的链接 → 全仓搜索」——前两步命不中，就可能按缺失处理。

---

## 7. 常见坑（前几届同学用血换来的）

| 坑 | 现象 | 正确做法 |
| :-: | :- | :- |
| **从 main 切 M2** | M2 分支里没有 M1 代码，系统跑不起来；MR diff 一片混乱 | M{n} 一律从 `milestone/m{n-1}` 切（[§4.2](#42-之后每一次开-mn--n--1从上一里程碑切)） |
| **手滑点了 Merge** | MR 被合并进目标分支，评审面破坏 | **别点。** 不小心点了，立刻在群里 @ 助教说明，不要自行 close |
| **报告图片挂掉** | MR 里图片全是裂图 | 截图统一放 `docs/m{n}/screenshots/`，用相对路径引用；开 MR 后在网页核对一遍 |
| **一个 commit 交全卷** | `initial commit` 一个巨包，看不出改了啥 | 小步、多次、语义化 commit：`feat(m2): ...`、`fix(m2): ...`、`docs(m2): ...` |
| **报告用 docx/pdf** | AI 助教解析不出来，直接判扣分 | 报告一律 Markdown（`docs/m{n}/report.md`），禁止 doc/pdf |
| **忘了 push 或忘了开 MR** | 「我明明 commit 了啊」——但助教什么都看不到 | commit 是本地的；**push + 开 MR + @ 助教** 才是交卷 |
| **在不同里程碑分支之间乱切着改** | 分支互相串味，出现「平行宇宙」 | 一次只做一个里程碑；切换前 `git status` 确认干净，新分支只从上一里程碑切 |
| **给必备锚点文件「起个好听的名字」** | `report.md` 改成 `实验报告.md`、`playbook.md` 改成 `手册.md`——助教按锚点找不到，按缺失处理 | §6.2 标「必备」的文件名一个字都别改；想自由发挥的部分见 §6.3 |
| **把密钥 / token 提交进仓库** | LLM 的 API key、GitLab token 写进代码或 `.env` 并 push——触发安全红线，安全维度直接判不合格 | 密钥一律走环境变量或本地 `.env`，并把 `.env` 写进 `.gitignore`；已经误推的立刻作废换新的，再联系助教 |

---

## 8. 一页速查表

```bash
# ===== 开启里程碑 M{n}（n≥1；M0 见 §4.1）=====
git switch milestone/m$((n-1))        # ① 回到上一里程碑分支（非 main）
git pull origin milestone/m$((n-1))   # ② 拉最新
git switch -c milestone/m$n           # ③ 切新分支
# ④ 边做边 commit：  git commit -m "feat(m$n): ..."
git push -u origin milestone/m$n      # ⑤ 推送
# ⑥ GitLab 开 MR：源=milestone/m$n，目标=milestone/m$((n-1))，@助教，保持 Open
```

| 里程碑 | 分支 | MR 目标 |
| :-: | :- | :- |
| M0 | `milestone/m0` | `main` |
| M1 | `milestone/m1` | `milestone/m0` |
| M2 | `milestone/m2` | `milestone/m1` |
| M3 | `milestone/m3` | `milestone/m2` |
| M4 | `milestone/m4` | `milestone/m3` |
| M5 | `milestone/m5` | `milestone/m4` |
| M6 | `milestone/m6` | `milestone/m5` |
| M7 | `milestone/m7` | `milestone/m6` |

> 学期末：所有里程碑评审完成后，把 `milestone/m7` 合回 `main`（届时助教会统一指导）。

---

## 9. 和 Linux 课的 Git 流程有何不同

如果你上学年用过 Linux 课那套，**唯一的概念差异**就是切分支的起点：

| | Linux 课（每单元独立） | 本学期综合实践项目（渐进累积） |
| :- | :- | :- |
| 切新分支的起点 | 永远从 **`main`** 切 | 从 **上一里程碑分支** 切（M0 才从 main） |
| 单元/里程碑之间 | 互相独立、互不依赖 | 累积，后一个盖在前一个之上 |
| 标记方式 | 分支（无 tag） | 分支（无 tag）✅ 这条一样 |
| MR 目标 | `main` | 上一里程碑分支（M0→main） |
| 合并 | 不合并，保持 `Open` | 不合并，保持 `Open` ✅ 这条一样 |
| 单元/里程碑产物隔离 | 靠「分支同名目录」 | 靠 `docs/m{n}/` 目录 + 累积代码 |

一句话：**还是「分支 + MR + 不合并」那套，只是切新分支时要回到上一里程碑，而不是 main。** 原因是本学期的作品是一路长起来的，不是一堆互不相干的作业。

---

## 10. FAQ

**Q1：我做到 M3 时发现 M1 的代码有个 bug，要回去改 M1 吗？**
不用回退（那是高级操作，容易把后续分支搞乱）。**在当前 `milestone/m3` 分支里直接修掉**，commit message 写清楚（如 `fix(m1 的口令哈希): 在 m3 分支内修复`），并在 M3 的 `report.md` 里说明一句「发现并修复了 M1 的 XX 问题」。这叫 **fix-forward**，是工程上推荐的做法。

**Q2：我能不能用网页版 GitLab 直接编辑文件、不开本地分支？**
不推荐。本学期的代码要本地能跑（`python app.py`）、要做攻击/检测实验，几乎都得在本地改。请用本地 Git。

**Q3：commit message 写中文还是英文？**
都行，但要**说人话**——写清楚这次改了啥。推荐 Conventional Commits 风格：`feat(m2): ...`、`fix(m3): ...`、`docs(m0): ...`。

**Q4：可以用 AI 帮我写 commit message / 整理改动吗？**
可以。但 **`git push` 一律自己来**，且需在 `report.md` 注明用了哪个 AI 辅助 + 人工复核了什么。本课程**只允许国产大模型**（如 `deepseek-v4-flash` / Qwen / GLM / Kimi），**禁止** GPT/Claude/Gemini。

**Q5：我的 MR 目标选错了（选成 main 了）怎么办？**
在 MR 页面右侧 **Edit**，把 target branch 改回 `milestone/m{n-1}` 即可，不用重新建。

**Q6：为什么不能直接 push 到 main？**
因为 `main` 是冻结的「基线」，所有评审都基于「里程碑相对上一里程碑的增量」。直接动 main 会破坏所有 MR 的 diff，助教就无法判断每个里程碑各自做了什么。

**Q7：我想偷懒，不想记这些命令？**
没有也不建议依赖任何「一键脚本」——分支切错是学期级事故，手动操作一两个里程碑就形成肌肉记忆了。照着 [§8 一页速查表](#8-一页速查表) 逐行敲即可，全部命令就六行。

---

## 11. 检查清单（提交前自检）

- [ ] 当前分支名是 `milestone/m{n}`（不是 main、不是别的）
- [ ] 这个分支是从 `milestone/m{n-1}`（M0 则从 main）切出来的
- [ ] 本里程碑产物都在 `docs/m{n}/` 下，含 `report.md`（Markdown）
- [ ] 本里程碑的必备锚点文件齐全（对照 [§6.2](#62-逐里程碑规划)），自由命名的产物都在 `report.md` 里有相对链接
- [ ] `.gitlab-ci.yml` 存在，且最近一次 push 的 pipeline 是绿的（配置方法见 [CI 指南](ci-guide.md)）
- [ ] 报告里的图片在 MR 网页上能正常显示
- [ ] commit 是小步语义化的，没有「initial commit」巨包
- [ ] 已经 `git push` 到远端
- [ ] 已开 MR，**源=milestone/m{n}，目标=milestone/m{n-1}（或 main）**
- [ ] MR 保持 `Open`，没点 `Merge`、没点 `Close`
- [ ] 已在 MR 里 **@ 助教**
