#!/usr/bin/env bash
# new-milestone.sh — 一键开启下一个里程碑分支 + 推送 + 打印 GitLab「开 MR」链接
#
# 用法:  ./scripts/new-milestone.sh <n>      n = 0..7
# 例:    ./scripts/new-milestone.sh 2        # 从 milestone/m1 切出 milestone/m2 并推送
#
# 规范详见课程 Git 指南（courseware/unit00-intro/labs/git-guide.md）：
#   • 里程碑用分支 milestone/m0..m7 标记（不打 tag）
#   • M0 基于 main；M1..M7 基于上一里程碑分支
#   • 开 MR：源=milestone/m{n}，目标=milestone/m{n-1}（M0 目标=main），@助教，保持 Open

set -euo pipefail

# ---------- 参数校验 ----------
n="${1:-}"
if ! [[ "$n" =~ ^[0-7]$ ]]; then
  echo "用法: $0 <里程碑编号 0..7>" >&2
  echo "例:   $0 2    # 开启 milestone/m2（基于 milestone/m1）" >&2
  exit 1
fi

branch="milestone/m$n"
if [ "$n" -eq 0 ]; then
  base="main"
else
  prev=$((n - 1))
  base="milestone/m$prev"
fi

echo "▶ 准备开启里程碑 M$n"
echo "    新分支: $branch"
echo "    基线:   $base   （新分支从这里切出）"
echo

# ---------- 前置检查 ----------
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "✗ 当前目录不是 git 仓库。" >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "✗ 工作区有未提交的改动，请先 commit 或 stash：" >&2
  git status --short >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo "✗ 本地已存在分支 $branch。如确认要重开，先删掉它：  git branch -D $branch" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/$base"; then
  echo "✗ 找不到基线分支 $base。" >&2
  if [ "$n" -ne 0 ]; then
    echo "  请确认你已完成上一个里程碑 M$prev（应存在分支 milestone/m$prev）。" >&2
  else
    echo "  请确认你已 fork 种子工程且本地存在 main 分支。" >&2
  fi
  exit 1
fi

# ---------- 切到基线并拉新 ----------
echo "▶ 切到 $base ..."
git switch "$base"
if git remote get-url origin >/dev/null 2>&1; then
  echo "▶ 拉取最新 ..."
  git pull --ff-only origin "$base" || echo "  (拉取跳过：可能是首次推送或远端暂无此分支)"
fi

# ---------- 切新分支并推送 ----------
echo "▶ 创建 $branch ..."
git switch -c "$branch"

echo "▶ 推送到 origin ..."
git push -u origin "$branch"

# ---------- 生成 GitLab「开 MR」链接（预填源/目标）----------
remote="$(git remote get-url origin)"
web_url="$(printf '%s' "$remote" \
  | sed -e 's#\.git$##' \
        -e 's#^git@\([^:]*\):#https://\1/#' \
        -e 's#^https://[^@/]*@#https://#' )"

enc() {
  python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe=''))" "$1"
}
src=$(enc "$branch")
tgt=$(enc "$base")
mr_url="${web_url}/-/merge_requests/new?merge_request%5Bsource_branch%5D=${src}&merge_request%5Btarget_branch%5D=${tgt}"

# ---------- 收尾提示 ----------
echo
echo "✅ 分支 $branch 已就绪。"
echo
echo "下一步 —— 点下面的链接开 Merge Request（源/目标已自动填好）："
echo
echo "    $mr_url"
echo
echo "在 MR 页面别忘了："
echo "    • 标题：M$n <里程碑主题> 评审"
echo "    • Reviewer / Assignee 勾选助教  （这步 = 通知助教来批改）"
echo "    • 不要点 Merge、不要点 Close，保持 Open"
echo
echo "之后做实验、写 docs/m$n/report.md，小步 commit 后 git push 即可，MR 会自动更新。"
