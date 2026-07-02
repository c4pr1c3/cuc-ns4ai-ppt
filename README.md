# 网络安全（AI 时代版 · cuc-ns4ai-ppt）

配套 [《网络安全》本科生教材](https://github.com/c4pr1c3/cuc-ns) 的课件 —— **面向 AI 时代的实战单元化重构版**。

> 参照（不动）：源课件 [`cuc-ns-ppt`](https://github.com/c4pr1c3/cuc-ns-ppt)、风格/构建来源 [`Linux4AI`](https://github.com/c4pr1c3/Linux4AI)。
> 本课程已是 **16 学时讲授 + 48 学时实践**（且讲授将继续精简），范式从「知识章讲授」转为「**8 实战单元 · 边学边做**」：以一个渐进式「含 AI 的靶场 Web 应用」——综合实践项目（capstone，里程碑 M0-M7）——为学期主线，经典知识压成按需单元课件；经典全文通过 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/) 引用，本仓库不保留副本。

## 三大改造

| 维度 | 改造 |
| :-: | :- |
| **内容** | 13 章 → **8 实战单元 U0-U7**（≈ 综合实践项目 M0-M7）；经典章改 [在线引用](https://github.com/c4pr1c3/cuc-ns-ppt/)（本仓库不留副本）；AI 脊柱织入 U6 专题 + U4/U5 埋伏 |
| **教学法** | [`/teachme`](https://github.com/c4pr1c3/teachme) 七要素撰写 + `study/` 助学层（学习指南 + 题库，兼容 `quiz-generator`） |
| **构建/样式** | 全量迁移 Linux4AI：`hakimel/reveal.js` 5.x + `linux4ai.css` + `build_slides.sh`（slides/labs 分离），与 Linux4AI 视觉统一 |

## 构建

```bash
# 1. 初始化 reveal.js 子模块（首次必做，需联网）
git submodule update --init --recursive

# 2. 渲染 slides + docs（pandoc 3.x）
bash build_slides.sh

# 3.（可选/开发期）slide 超高自测：改完 slides 提交前跑，CI 不再做此校验
npm install && npx playwright install chromium   # 首次
npm run check:overflow                           # slide 超高自测
npm run check:links                              # 首页注册 + 全页相对链接可达（加新页后）
npm run check:links:fix                          # 自动修「多 ../」类断链
```

- **slides**（reveal.js + highlight.js monokai）：仅 `courseware/**/slides/*.md`
- **docs**（纯 HTML + `linux4ai.css` + toc + pandoc skylighting tango 高亮）：`courseware/**/labs/*.md` + `study/**/*.md` + `capstone/*.md` + 顶层 `index/syllabus/capability-framework`
- 输出 `.html` 与源 `.md` 同目录。CI：`.github/workflows/render.yml`（仅渲染+部署，超高自测已移出 CI）。

## 目录约定

- `courseware/unitNN-name/{slides,labs}/`：每个单元 = 问题引入 + 实战实验（综合实践项目里程碑）+ 按需课件。
- `capstone/`：渐进式作品主线（`overview.md` + `m6-ai.md` + `seed/` 学生起点）。
- `study/`：[teachme](https://github.com/c4pr1c3/teachme) 助学层（`unitNN-{guide,quiz}.md`）；经典章全文见 [cuc-ns-ppt 在线仓库](https://github.com/c4pr1c3/cuc-ns-ppt/)（本仓库不保留副本）。
- slides 格式：YAML frontmatter（`title/subtitle/author/date/output`）、`---` 分页、`# Topic` H1 / `## Slide` H2、代码块 ` ```{.lang .numberLines} `（slides 经 `revealjs-codeblock.lua` 转 `data-line-numbers`；docs 由 pandoc 内联 CSS 渲染行号）。
