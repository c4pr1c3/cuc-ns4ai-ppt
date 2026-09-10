#!/bin/bash
# check_links_resolve.sh — 本地开发工具
# 扫描所有「被 build_slides.sh 渲染的 .md」里的相对链接 [text](target)，检测目标是否可达（404）。
#
# 与 check_index_registration.sh 互补：
#   - 后者查「首页 index.md 是否引用了每个渲染页面」（注册）；
#   - 本脚本查「每个渲染页面里的相对链接是否指向真实存在的文件」（可达）——
#     防止下沉页面（如 slides）里的错层 ../ 、删文件忘改链接 等溜进线上。
#
# 用法：
#   bash scripts/check_links_resolve.sh            # 仅扫描、报告，有断链则 exit 1
#   bash scripts/check_links_resolve.sh --fix      # 额外自动修「多写了 ../」类断链（保守，先全扫后改）
#   npm run check:links                            # = 注册校验 && 本脚本
#
# 只查 markdown 链接里的目标路径；跳过外链(scheme:)、纯锚点(#)、mailto:；去 #fragment / ?query。
# 详见 AGENTS.md §3。
set -uo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "$ROOT"

FIX=0
[ "${1:-}" = "--fix" ] && FIX=1

TMPF="$(mktemp)"; TMPB="$(mktemp)"
trap 'rm -f "$TMPF" "$TMPB"' EXIT

# --- 1) 收集渲染范围内的 .md（镜像 build_slides.sh / check_index_registration.sh 的 glob）---
{
    find courseware -type f -path '*/slides/*.md' ! -name '*.ai-ta.md' 2>/dev/null
    find courseware -type f -path '*/labs/*.md'  ! -name '*.ai-ta.md' 2>/dev/null
    find study -type f -name '*.md' ! -name '*-quiz-answers.md' 2>/dev/null
    find capstone -maxdepth 1 -type f -name '*.md' ! -name '*.ai-ta.md' 2>/dev/null
    for top in index.md syllabus.md capability-framework.md; do
        [ -f "$top" ] && echo "$top"
    done
} | sort -u > "$TMPF"

# --- 2) 全扫：逐文件抽 ](target)，跳过外链/锚点，判定可达；断链入 TMPB（含建议）---
scanned=0
while IFS= read -r f; do
    [ -f "$f" ] || continue
    dir="$(dirname "$f")"
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        lno="${line%%:*}"            # 行号
        match="${line#*:}"           # ](target)
        target="${match:2}"          # target)
        target="${target%)}"         # target
        target="${target%%#*}"       # 去 fragment
        target="${target%%\?*}"      # 去 query
        [ -z "$target" ] && continue
        # 跳过外链（带 scheme）、纯锚点
        [[ "$target" =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]] && continue
        [[ "$target" =~ ^# ]] && continue
        scanned=$((scanned+1))
        if [ ! -e "$dir/$target" ]; then
            # 建议：逐个去掉前导 ../，找第一条可达路径
            suggest=""
            t="$target"
            while [[ "$t" == ../* ]]; do
                t="${t#../}"
                if [ -e "$dir/$t" ]; then suggest="$t"; break; fi
            done
            printf '%s\t%s\t%s\t%s\n' "$f" "$lno" "$target" "$suggest" >> "$TMPB"
        fi
    done < <(grep -noE '\]\([^)]+\)' "$f" 2>/dev/null)
done < "$TMPF"

# --- 3) 报告 +（可选）修复 ---
broken=$(wc -l < "$TMPB" | tr -d ' ')
if [ "$broken" -eq 0 ]; then
    echo "[resolve] 扫描 $(wc -l < "$TMPF" | tr -d ' ') 个渲染 .md | 相对链接 $scanned 条 | 断链 0 ✅"
    exit 0
fi

echo "[resolve] 扫描 $(wc -l < "$TMPF" | tr -d ' ') 个渲染 .md | 相对链接 $scanned 条 | 断链 $broken"
if [ "$FIX" = "0" ]; then
    echo "---- 断链清单（用 --fix 可自动修「多 ../」类）----"
    while IFS=$'\t' read -r f lno target suggest; do
        [ -n "$suggest" ] && echo "  ❌ $f:$lno  ($target)  建议 → ($suggest)" \
                           || echo "  ❌ $f:$lno  ($target)  目标不存在（减 ../ 也无可达路径，需手动）"
    done < "$TMPB"
    exit 1
fi

# FIX=1：先报告全貌，再对「有建议」的逐条 sed 修正
fixed=0
echo "---- 断链清单（--fix：自动修可修的）----"
while IFS=$'\t' read -r f lno target suggest; do
    if [ -n "$suggest" ]; then
        sed -i "${lno}s|(${target})|(${suggest})|" "$f"
        fixed=$((fixed+1))
        echo "  🔧 已修 $f:$lno  ($target) → ($suggest)"
    else
        echo "  ⚠️ 未修 $f:$lno  ($target)  目标不存在，需手动"
    fi
done < "$TMPB"

remaining=$((broken - fixed))
echo "[resolve] 自动修复 $fixed/$broken"
if [ "$remaining" -gt 0 ]; then
    echo "⚠️ 仍有 $remaining 条断链（目标不存在）需手动处理。"
    exit 1
fi
echo "✅ 全部断链已修；建议再跑一遍 \`npm run check:links\` 复核。"
exit 0
