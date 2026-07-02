#!/bin/bash
# 基于 Linux4AI/build_slides.sh 适配的《网络安全（AI 时代版）》构建脚本。
# - slides (reveal.js)：仅 courseware/**/slides/*.md
# - docs   (LAB 样式：纯 HTML + linux4ai.css + toc + markdown-body)：
#          courseware/**/labs/*.md + study/**/*.md + 顶层 deck(index/syllabus/capability-framework) + capstone/*.md
# 放弃了原 render.sh 的 4 变体/multiplex（与「少讲授多动手」范式不再契合）。
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"
REVEALJS_DIR_NAME="reveal.js"
REVEALJS_PATH="$PROJECT_ROOT/$REVEALJS_DIR_NAME"
TEMPLATE_FILE="$PROJECT_ROOT/revealjs.template"
LUA_FILTER="$PROJECT_ROOT/revealjs-codeblock.lua"

if ! command -v pandoc &> /dev/null; then
    echo "错误: 未找到 pandoc。请先安装 pandoc。"; exit 1
fi
if [ ! -d "$REVEALJS_PATH" ]; then
    echo "警告: 未找到 $REVEALJS_PATH，尝试初始化子模块..."
    git submodule update --init --recursive
    [ -d "$REVEALJS_PATH" ] || { echo "错误: 无法获取 reveal.js 子模块。"; exit 1; }
fi
[ -f "$PROJECT_ROOT/styles.html" ] || touch "$PROJECT_ROOT/styles.html"

# 代码块 .numberLines 等属性过滤器（可选存在）
LINKS_FILTER="$PROJECT_ROOT/links-to-html.lua"   # 仓库内 .md 链接 → .html（渲染期重写），slides/docs 共用
# slides 需 revealjs-codeblock.lua（把 .numberLines 转 reveal.js 的 data-line-numbers）；
# docs 只用链接重写——其代码高亮/行号由 pandoc skylighting（--highlight-style）内联负责。
SLIDE_LUA_ARGS=""
DOC_LUA_ARGS=""
[ -f "$LUA_FILTER" ] && SLIDE_LUA_ARGS="-L $LUA_FILTER"
[ -f "$LINKS_FILTER" ] && SLIDE_LUA_ARGS="$SLIDE_LUA_ARGS -L $LINKS_FILTER"
[ -f "$LINKS_FILTER" ] && DOC_LUA_ARGS="-L $LINKS_FILTER"

render_slide() {
    local file="$1" dir output_file rel_path_to_root revealjs_url css_url
    dir="$(dirname "$file")"
    output_file="${file%.md}.html"
    rel_path_to_root="$(realpath --relative-to="$dir" "$PROJECT_ROOT")"
    revealjs_url="$rel_path_to_root/$REVEALJS_DIR_NAME"
    css_url="$rel_path_to_root/css/linux4ai.css"
    echo "[slides] $file"
    pandoc -t revealjs -s -o "$output_file" "$file" \
        -V revealjs-url="$revealjs_url" \
        --template="$TEMPLATE_FILE" \
        -V theme=white \
        --css="$css_url" \
        -V transition=fade \
        -V history=true \
        --no-highlight \
        -V hlss=kate \
        --slide-level=2 \
        --mathjax \
        $SLIDE_LUA_ARGS
}

render_doc() {
    local file="$1" dir output_file rel_path_to_root css_url js_url title
    dir="$(dirname "$file")"
    output_file="${file%.md}.html"
    rel_path_to_root="$(realpath --relative-to="$dir" "$PROJECT_ROOT")"
    css_url="$rel_path_to_root/css/linux4ai.css"
    js_url="$rel_path_to_root/js/toc.js"
    title="$(sed -n 's/^#\{1,\}[[:space:]]\+//p' "$file" | head -n 1)"
    [ -z "$title" ] && title="$(basename "${file%.md}")"
    echo "[doc]    $file"
    # 返回首页：非首页 doc 在顶部注入「← 返回首页」（pandoc 原生 --include-before-body，
    # 路径按 rel_path_to_root 计算，子目录页面也能正确指回根 index.html；首页 index.md 自身跳过）
    local before_body=""
    if [ "$(basename "$file")" != "index.md" ]; then
        before_body="$(mktemp)"
        printf '<div class="doc-home"><a href="%s/index.html">← 返回首页</a></div>\n' "$rel_path_to_root" > "$before_body"
    fi
    # LAB 样式：--toc + markdown-body body class + toc.js 注入
    # 代码高亮走 pandoc 服务端 skylighting（tango 浅色主题，区别于 slides 的 reveal.js monokai），
    # 着色 + .numberLines 行号 CSS 由 -s 自动内联进 head，无需客户端 JS。
    pandoc -s -o "$output_file" "$file" \
        --css="$css_url" \
        --highlight-style=tango \
        --toc \
        --metadata title="$title" \
        ${before_body:+--include-before-body=$before_body} \
        $DOC_LUA_ARGS
    [ -n "$before_body" ] && rm -f "$before_body"
    sed -i 's/<body>/<body class="markdown-body">/' "$output_file"
    sed -i "s|</body>|<script src=\"$js_url\"></script></body>|" "$output_file"
}

echo "==========================================="
echo "项目根: $PROJECT_ROOT"
echo "==========================================="

# 1) 单元 slides
find "$PROJECT_ROOT" \
    -type d \( -name .git -o -name "$REVEALJS_DIR_NAME" -o -name node_modules -o -name .omc -o -name old -o -name dist \) -prune -o \
    -type f -path "*/slides/*.md" -print0 | while IFS= read -r -d '' f; do render_slide "$f"; done

# 2) 顶层 deck（统一为 LAB 文档样式，不再用 reveal.js）
for top in index.md syllabus.md capability-framework.md; do
    [ -f "$PROJECT_ROOT/$top" ] && render_doc "$PROJECT_ROOT/$top"
done

# 3) capstone/*.md（仅直接子文件；seed/ 下为代码 README，不渲染；统一为 LAB 文档样式）
[ -d "$PROJECT_ROOT/capstone" ] && find "$PROJECT_ROOT/capstone" -maxdepth 1 -type f -name '*.md' ! -name '*.ai-ta.md' -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

# 4) 单元 labs
find "$PROJECT_ROOT" \
    -type d \( -name .git -o -name "$REVEALJS_DIR_NAME" -o -name node_modules -o -name .omc -o -name old -o -name dist \) -prune -o \
    -type f -path "*/labs/*.md" ! -name '*.ai-ta.md' -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

# 5) study/ 下所有 md（助学指南/题库/参考）→ 纯 HTML
[ -d "$PROJECT_ROOT/study" ] && find "$PROJECT_ROOT/study" -type f -name '*.md' -not -name '*-quiz-answers.md' -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

echo "转换完成！"
echo '（slide 超高自测已移出构建——开发期用 `npm run check:overflow` 自测，CI 不再做该校验）'
