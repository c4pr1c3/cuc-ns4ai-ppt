-- links-to-html.lua — pandoc Lua 过滤器
-- 渲染期把「仓库内 .md 链接目标」重写为 .html，使源码用 .md（GitHub/编辑器不 404）、
-- 渲染产物用 .html（站点内跳转正确）。输出树与源树同构，相对位置自动正确。
--
-- 规则：
--   - 仅处理 Link 行内节点（Image 是独立 AST 节点，不受影响——图片 .png/.jpg 等不动）。
--   - 跳过：带 scheme（http/https/mailto/...）、仅锚点（#sec）、目标不以 .md 结尾。
--   - 保留 #fragment：foo.md#sec → foo.html#sec。
--   - 目录链接（如 seed/）与无扩展名链接不动。
function Link(el)
  local u = el.target
  if u == nil or u == "" then return el end
  if u:match("^%a[%w+.-]*:") then return el end      -- 带 scheme（http/mailto/...）
  if u:sub(1, 1) == "#" then return el end            -- 仅锚点
  -- 拆出 fragment
  local path, frag = u:match("^(.-)(#.*)$")
  path = path or u
  frag = frag or ""
  if path:match("%?.*$") then return el end           -- 含 query 串的保守不处理（仓库内无此链接）
  if not path:match("%.md$") then return el end       -- 只重写 .md 目标
  el.target = path:gsub("%.md$", ".html") .. frag
  return el
end
