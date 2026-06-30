# 网络安全（AI 时代版 · cuc-ns4ai-ppt）

配套 [《网络安全》本科生教材](https://github.com/c4pr1c3/cuc-ns) 的课件 —— **面向 AI 时代的实战单元化重构版**。

> 参照（不动）：源课件 [`cuc-ns-ppt`](https://github.com/c4pr1c3/cuc-ns-ppt)、风格/构建来源 [`Linux4AI`](https://github.com/c4pr1c3/Linux4AI)。
> 本课程已是 **16 学时讲授 + 48 学时实践**（且讲授将继续精简），范式从「知识章讲授」转为「**8 实战单元 · 边学边做**」：以一个渐进式「含 AI 的靶场 Web 应用」（capstone M0-M7）为学期主线，经典知识压成 just-in-time 单元 slides；经典全文通过 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/) 引用，本仓库不保留副本。

## 三大改造

| 维度 | 改造 |
| :-: | :- |
| **内容** | 13 章 → **8 实战单元 U0-U7**（≈ capstone M0-M7）；经典章改 [在线引用](https://github.com/c4pr1c3/cuc-ns-ppt/)（本仓库不留副本）；AI 脊柱织入 U6 专题 + U4/U5 埋伏 |
| **教学法** | `/teachme` 七要素撰写 + `study/` 助学层（学习指南 + 题库，兼容 `quiz-generator`） |
| **构建/样式** | 全量迁移 Linux4AI：`hakimel/reveal.js` 5.x + `linux4ai.css` + `build_slides.sh`（slides/labs 分离），与 Linux4AI 视觉统一 |

## 构建

```bash
# 1. 初始化 reveal.js 子模块（首次必做，需联网）
git submodule update --init --recursive

# 2. 渲染 slides + docs（pandoc 3.x）
bash build_slides.sh
```

- **slides**（reveal.js）：`courseware/**/slides/*.md` + 顶层 `index/syllabus/capability-framework` + `capstone/*.md`
- **docs**（纯 HTML + `linux4ai.css` + toc）：`courseware/**/labs/*.md` + `study/**/*.md`
- 输出 `.html` 与源 `.md` 同目录。CI：`.github/workflows/render.yml`。

## 目录约定

- `courseware/unitNN-name/{slides,labs}/`：每个单元 = 问题 hook + 实战 lab（capstone 里程碑）+ just-in-time slides。
- `capstone/`：渐进式作品主线（`overview.md` + `m6-ai.md` + `seed/` 学生起点）。
- `study/`：teachme 助学层（`unitNN-{guide,quiz}.md`）+ `reference/`（经典章全文按需自学）。
- slides 格式：YAML frontmatter（`title/subtitle/author/date/output`）、`---` 分页、`# Topic` H1 / `## Slide` H2、代码块 `.lang .numberLines`（经 `revealjs-codeblock.lua`）。

## 撰写状态

✅ 迁移 + 骨架 + 旗舰单元 U6/U0；📝 U1/U3/U4/U5/U7 待增量撰写。路线图见 `syllabus.md` 末「撰写路线图」。
