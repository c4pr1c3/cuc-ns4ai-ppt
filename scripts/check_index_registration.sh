#!/bin/bash
# check_index_registration.sh — 本地开发工具
# 校验所有「被 build_slides.sh 渲染的 .md」是否都在首页 index.md 注册（有链接可达）。
#
# 做法：镜像 build_slides.sh 的渲染 glob 收集「已渲染源 .md」集合 R；
#       解析 index.md 的 markdown 链接目标得到集合 L；
#       孤儿 = R − L − 白名单（深度资料无需进首页）。
#       有可操作孤儿 → exit 1，干净 → exit 0。
#
# 用法： bash scripts/check_index_registration.sh    或    npm run check:links
# 详见 AGENTS.md §3。注册校验是开发期职责，不进 CI、不耦合进 build_slides.sh。
set -uo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "$ROOT"

INDEX="index.md"
[ -f "$INDEX" ] || { echo "错误：未找到 $INDEX"; exit 2; }

TMP_R="$(mktemp)"; TMP_L="$(mktemp)"; TMP_W="$(mktemp)"; TMP_O="$(mktemp)"
trap 'rm -f "$TMP_R" "$TMP_L" "$TMP_W" "$TMP_O"' EXIT

# --- 1) 收集「已渲染源 .md」集合 R（镜像 build_slides.sh 的 glob，见其 86-104 行）---
{
    find courseware -type f -path '*/slides/*.md' 2>/dev/null          # 1) 单元 slides
    find courseware -type f -path '*/labs/*.md' ! -name '*.ai-ta.md' 2>/dev/null  # 4) 单元 labs（排除 AI 助教信号）
    find study -type f -name '*.md' ! -name '*-quiz-answers.md' 2>/dev/null  # 5) study（排除答案）
    find capstone -maxdepth 1 -type f -name '*.md' ! -name '*.ai-ta.md' 2>/dev/null  # 3) capstone（排除 AI 助教信号）
    for top in index.md syllabus.md capability-framework.md; do        # 2) 顶层 deck
        [ -f "$top" ] && echo "$top"
    done
} | sed 's#^\./##' | sort -u > "$TMP_R"

# --- 2) 收集 index.md 的 .md 链接目标（仓库相对路径）---
# 抽 [text](target) 里的 target，去外链/锚点/query，只留 .md 目标
grep -oE '\]\([^)]+\)' "$INDEX" \
    | sed 's/^](//; s/)$//' \
    | grep -vE '^[a-z][a-z0-9+.-]*://' \
    | sed 's/[#?].*$//' \
    | grep -E '\.md$' \
    | sort -u > "$TMP_L" || true

# --- 3) 白名单：无需进首页的深度资料 / 首页自身 ---
cat > "$TMP_W" <<'EOF'
index.md
study/ai-pentest-resources.md
study/explainer-data-as-program.md
study/explainer-prompt-injection-loop.md
study/explainer-stride-intuition.md
study/references-curated.md
EOF
sort -u "$TMP_W" -o "$TMP_W"

# --- 4) 孤儿 = R − (L ∪ 白名单) ---
comm -23 "$TMP_R" <(cat "$TMP_L" "$TMP_W" | sort -u) > "$TMP_O"

echo "已渲染源 .md：$(wc -l < "$TMP_R") 个 | index.md 内链：$(wc -l < "$TMP_L") 个 | 白名单：$(wc -l < "$TMP_W") 个"

if [ -s "$TMP_O" ]; then
    echo
    echo "⚠️  发现未在首页注册的页面（$(wc -l < "$TMP_O") 个）："
    while IFS= read -r f; do echo "  - $f"; done < "$TMP_O"
    echo
    echo "请在 index.md 为上述页面补充链接（源里写 .md 目标，渲染期 links-to-html.lua 自动重写为 .html）。"
    exit 1
fi
echo "✅ 所有应进首页的页面均已注册（或属白名单）。"
exit 0
