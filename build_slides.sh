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
LUA_ARGS=""
[ -f "$LUA_FILTER" ] && LUA_ARGS="-L $LUA_FILTER"

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
        $LUA_ARGS
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
    # LAB 样式（对齐 build_pages.sh 的 LAB_MD_FILES 渲染）：--toc + markdown-body body class + toc.js 注入
    pandoc -s -o "$output_file" "$file" \
        --css="$css_url" \
        --toc \
        --metadata title="$title" \
        $LUA_ARGS
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
[ -d "$PROJECT_ROOT/capstone" ] && find "$PROJECT_ROOT/capstone" -maxdepth 1 -type f -name '*.md' -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

# 4) 单元 labs
find "$PROJECT_ROOT" \
    -type d \( -name .git -o -name "$REVEALJS_DIR_NAME" -o -name node_modules -o -name .omc -o -name old -o -name dist \) -prune -o \
    -type f -path "*/labs/*.md" -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

# 5) study/ 下所有 md（助学指南/题库/参考）→ 纯 HTML
[ -d "$PROJECT_ROOT/study" ] && find "$PROJECT_ROOT/study" -type f -name '*.md' -print0 | while IFS= read -r -d '' f; do render_doc "$f"; done

echo "==========================================="
# 6) 渲染后自测：检测 slide 超高溢出（需 node + Playwright；缺失则跳过）
if command -v node >/dev/null 2>&1 && [ -f "$PROJECT_ROOT/scripts/check_slide_overflow.mjs" ]; then
    if [ -d "$PROJECT_ROOT/node_modules/playwright" ]; then
        echo "---"
        echo "[check] slide 超高自测..."
        node "$PROJECT_ROOT/scripts/check_slide_overflow.mjs" && check_rc=0 || check_rc=$?
        if [ "$check_rc" -ne 0 ]; then
            echo "[check] ⚠️ 发现超高 slide，请按提示拆分对应 markdown 后重新构建。"
            # CI 门控：SLIDE_OVERFLOW_GATE=1 时超高即失败，阻止部署被裁剪的 slide
            if [ "${SLIDE_OVERFLOW_GATE:-0}" = "1" ]; then
                exit 1
            fi
        fi
    else
        echo "[check] 未安装 playwright，跳过超高自测（npm install && npx playwright install chromium 后启用）"
    fi
fi

echo "转换完成！"
