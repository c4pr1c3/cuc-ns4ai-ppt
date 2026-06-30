---
title: "AI 助学层使用说明"
author: 黄玮
---

# AI 助学层是什么

> 每个实战单元配套一份「**学习指南** + **题库**」，由 `/teachme` 按「七要素」生成，把课件里的「点」展开为「网」与「练」，供学生自学自测。

## 目录约定

| 文件 | 角色 |
| :- | :- |
| `study/unitNN-guide.md` | 学习指南（七要素：动机/直觉/流程/实战/误区/自测/延伸） |
| `study/unitNN-quiz.md` | 题库（单选/多选/判断 + 场景题） |
| [cuc-ns-ppt 在线](https://github.com/c4pr1c3/cuc-ns-ppt/) | 经典 13 章 + `llm-security.md` + `vuls-awd.md`（按需自学，**本仓库不保留副本**） |
| `study/README.md` | 本说明 |

* 当前样板：[`unit06-guide.md`](unit06-guide.html) / [`unit06-quiz.md`](unit06-quiz.html)
* 由 `build_slides.sh` 渲染为**纯 HTML 文档**（`css/linux4ai.css` + 侧边 toc）。

## 与课件的关系

* 课件（`courseware/unitNN/slides/`）= 教师 just-in-time 讲授主线
* 助学层（`study/`）= 学生自学 + 自测的伴生层；经典深度理论在 `reference/`

# teachme 标准调用约定

## 四个对齐维度（Stage 1 固定答法）

| 维度 | 本课取值 | 理由 |
| :- | :- | :- |
| **受众** | 网安本科生 | 有系统/网络基础，AI 工具新手 |
| **核心目标** | 建立直觉 + 掌握使用 | 追求「能上手」 |
| **输出形式** | pandoc-markdown | 直接进 `build_slides.sh` |
| **深度** | 配套一个单元的助学 | 一单元一指南 + 一题库 |

## 按单元调用 teachme 的可复用 prompt 模板

```text
请为「第 N 单元 <单元标题>」生成助学产物，受众=网安本科生，
核心目标=建立直觉+掌握使用，输出形式=pandoc-markdown，深度=配套本单元的助学。
阅读 courseware/unitNN-* / slides 与 labs 原文，确保口径一致。

产出两个文件到 study/：
1) study/unitNN-guide.md —— 学习指南（七要素：动机/直觉/关键流程/实战要点/
   常见误区/自测要点/延伸），frontmatter: title / author: 黄玮，中文为主。
2) study/unitNN-quiz.md —— 题库：8-10 单选 + 3-4 多选 + 3-4 判断 + 2-3 场景题，
   难度从认知到实践判断。每题格式：
       ### Qn  [题型]
       题干……
       - A. ……
       > 答案：B
       > 解析：……
```

# 题库格式与 quiz-generator 的映射

> **一句话**：题库的「题型标签 + 题干 + 选项 + `> 答案` + `> 解析`」五段，对应 `quiz-generator` 的「题型 / stem / options / answer / explanation」，按单元抽取即可随机组卷。

````markdown
### Q1  [单选]
中型 SOC 每天产生数万告警，真阳性占比通常约为？
- A. >50%
- B. 20% 左右
- C. < 1%
- D. 100%
> 答案：<公开题库不含答案 · 见 internal 版>
> 解析：<答案与解析仅存于 internal 分支的 study/unitNN-quiz-answers.md>
````

# 再生与刷新

* AI（尤其 LLM 安全）迭代快，**每学期可按模板重新生成**
* 流程：更新单元 slides/labs → 重跑 teachme prompt → `bash build_slides.sh`
* `reference/` 的经典章随教材更新而同步

## 质量底线（生成后自检）

- [ ] 指南覆盖七要素；题库覆盖本单元全部知识点、难度有梯度
- [ ] 每题答案/解析准确、无幻觉
- [ ] `bash build_slides.sh` 渲染 exit=0、clean

## 当前覆盖

* **已覆盖（样板）**：U6 AI 赋能与对抗（`unit06-guide.md` / `unit06-quiz.md`）
* **待覆盖**：U0-U5、U7 按同一模板生成
