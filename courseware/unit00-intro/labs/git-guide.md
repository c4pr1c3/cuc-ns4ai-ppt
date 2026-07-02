# Git 操作指南与规范（本学期综合实践项目专用）

> 这是《网络安全（AI 时代版）》渐进式作品（综合实践项目 M0–M7）的**唯一** Git 提交规范。
> 适用对象：所有学生，**尤其是自认为 Git 基础薄弱的同学**——按本指南照做即可，不需要额外看其它教程。
> 配套：[综合实践项目总览](../../../capstone/overview.md) · [种子工程](../../../capstone/seed/README.md) · [实验 00 / M0](lab00-threat-model.md)

---

## 1. 为什么本学期要单独讲 Git

如果你上学年上过 Linux 课，会记得它教的 Git 流程：**每个单元从 `main` 切一个分支、建同名目录、开一个 MR、保持 open 不合并**。那套流程对「每单元独立」的作业是对的。

**但本学期不一样**：整学期只做一个工程——一个「含 AI 能力的靶场 Web 应用」，按里程碑 M0→M7 **渐进迭代**。也就是说：

> **M2 的代码踩在 M1 上，M1 踩在 M0 上……同一个仓库、同一套代码，一路长成一个完整系统。**

这条「累积」性质，直接决定了 Git 的用法必须改。具体改在哪，见 [§8 和 Linux 课的差异](#8-和-linux-课的-git-流程有何不同)。先记住下面三条铁律即可。

---

## 2. 三条铁律（先记住这三条）

| # | 铁律 | 一句话 |
| :-: | :- | :- |
| ① | **用分支标记里程碑** | 完成一个里程碑 = 开一个名为 `milestone/m{n}` 的分支；**不再打 tag**。 |
| ② | **用 MR 叫助教来批改** | 分支推上去后，开一个 Merge Request 并 **@助教**（把助教勾选为 reviewer）。**只 push 代码 ≠ 交卷**，开了 MR 且 @ 了助教才算交卷。 |
| ③ | **不合并不关闭，学期末才收尾** | 每个 MR **保持 open**：不要点 Merge、不要 Close。每个 MR 只含**一个里程碑**的内容。学期全部结束、所有 M 评审完成后，再把最终的 `milestone/m7` 合回 `main`。 |

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

# ③ 做 M2 的实验，产物放进 docs/m2/
git add docs/m2/
git commit -m "feat(m2): 暴露面清单 + 参数化侦察脚本"
# ...边做边 commit...

# ④ 推送
git push -u origin milestone/m2
```

然后开 MR：**源 = `milestone/m2`，目标 = `milestone/m1`**（目标务必选上一里程碑分支，不要选 main）。

> 把上面这段里的 `m1`/`m2` 换成你当前的里程碑编号即可，每个里程碑重复一次。

### 4.3 一行总结 ritual

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

## 6. 常见坑（前几届同学用血换来的）

| 坑 | 现象 | 正确做法 |
| :-: | :- | :- |
| **从 main 切 M2** | M2 分支里没有 M1 代码，系统跑不起来；MR diff 一片混乱 | M{n} 一律从 `milestone/m{n-1}` 切（[§4.2](#42-之后每一次开-mn--n--1从上一里程碑切)） |
| **手滑点了 Merge** | MR 被合并进目标分支，评审面破坏 | **别点。** 不小心点了，立刻在群里 @ 助教说明，不要自行 close |
| **报告图片挂掉** | MR 里图片全是裂图 | 截图统一放 `docs/m{n}/screenshots/`，用相对路径引用；开 MR 后在网页核对一遍 |
| **一个 commit 交全卷** | `initial commit` 一个巨包，看不出改了啥 | 小步、多次、语义化 commit：`feat(m2): ...`、`fix(m2): ...`、`docs(m2): ...` |
| **报告用 docx/pdf** | AI 助教解析不出来，直接判扣分 | 报告一律 Markdown（`docs/m{n}/report.md`），禁止 doc/pdf |
| **忘了 push 或忘了开 MR** | 「我明明 commit 了啊」——但助教什么都看不到 | commit 是本地的；**push + 开 MR + @ 助教** 才是交卷 |
| **在不同里程碑分支之间乱切着改** | 分支互相串味，出现「平行宇宙」 | 一次只做一个里程碑；切换前 `git status` 确认干净，新分支只从上一里程碑切 |

---

## 7. 一页速查表

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

## 8. 和 Linux 课的 Git 流程有何不同

如果你上学年用过 Linux 课那套，**唯一的概念差异**就是切分支的起点：

| | Linux 课（每单元独立） | 本学期综合实践项目（渐进累积） |
| :- | :- | :- |
| 切新分支的起点 | 永远从 **`main`** 切 | 从 **上一里程碑分支** 切（M0 才从 main） |
| 单元/里程碑之间 | 互相独立、互不依赖 | 累积，后一个盖在前一个之上 |
| 标记方式 | 分支（无 tag） | 分支（无 tag）✅ 这条一样 |
| MR 目标 | `main` | 上一里程碑分支（M0→main） |
| 合并 | 不合并，保持 open | 不合并，保持 open ✅ 这条一样 |
| 单元/里程碑产物隔离 | 靠「分支同名目录」 | 靠 `docs/m{n}/` 目录 + 累积代码 |

一句话：**还是「分支 + MR + 不合并」那套，只是切新分支时要回到上一里程碑，而不是 main。** 原因是本学期的作品是一路长起来的，不是一堆互不相干的作业。

---

## 9. FAQ

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
种子工程自带 `scripts/new-milestone.sh`，一条命令自动定位上一里程碑分支、切新分支、推送、并打印一个**预填好目标分支**的 GitLab 开 MR 链接。想偷懒用它；想学原理就照 §4 手动来。

---

## 10. 检查清单（提交前自检）

- [ ] 当前分支名是 `milestone/m{n}`（不是 main、不是别的）
- [ ] 这个分支是从 `milestone/m{n-1}`（M0 则从 main）切出来的
- [ ] 本里程碑产物都在 `docs/m{n}/` 下，含 `report.md`（Markdown）
- [ ] 报告里的图片在 MR 网页上能正常显示
- [ ] commit 是小步语义化的，没有「initial commit」巨包
- [ ] 已经 `git push` 到远端
- [ ] 已开 MR，**源=milestone/m{n}，目标=milestone/m{n-1}（或 main）**
- [ ] MR 保持 **Open**，没点 Merge、没点 Close
- [ ] 已在 MR 里 **@ 助教**
