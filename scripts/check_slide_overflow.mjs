#!/usr/bin/env node
// check_slide_overflow.mjs
//
// Post-render self-test for reveal.js slides: detect <section>s whose content
// is taller than the slide box (the content reveal.js clips at the bottom).
//
// Principle: reveal.js scales `.slides` so the deck fits the window. At a viewport
// equal to the deck's configured base size (default 960x700, read from
// Reveal.getConfig()) the scale factor is 1, so each section is laid out at its
// true size. A section whose scrollHeight > clientHeight is exactly what gets
// clipped. We serve the project over a tiny local HTTP server so reveal.js +
// linux4ai.css load exactly as on the deployed site.
//
// Usage:
//   node scripts/check_slide_overflow.mjs                 # auto: courseware/**/slides/*.html
//   node scripts/check_slide_overflow.mjs path/a.html path/b.html
//   node scripts/check_slide_overflow.mjs --json ...      # machine-readable output
//
// Exit code: 1 if any overflowing slide is found, 0 otherwise.

import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { readdirSync } from 'node:fs';
import { extname, join, normalize, resolve, relative } from 'node:path';
import { chromium } from 'playwright';

// A slide clips when its content natural height (laid out at cfg.width) exceeds the
// slide canvas (cfg.height, default 700). reveal.js scales uniformly, so content taller
// than cfg.height is clipped regardless of zoom. Grace absorbs sub-pixel/font-metric noise.
const OVERFLOW_GRACE_PX = 8;
const ROOT = resolve(join(import.meta.dirname, '..'));

// --- collect slide HTML files -------------------------------------------------
function walk(dir, out) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (['.git', 'node_modules', 'reveal.js', 'dist', '.omc'].includes(e.name)) continue;
    const p = join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.isFile() && e.name.endsWith('.html') && p.includes('/slides/')) out.push(p);
  }
}

const argv = process.argv.slice(2);
const asJson = argv.includes('--json');
const pos = argv.filter((a) => !a.startsWith('--'));
let files = pos.length ? pos.flatMap((g) => g.split(' ')).map((p) => resolve(p)) : [];
if (!files.length) {
  files = [];
  walk(join(ROOT, 'courseware'), files);
}
files = files.filter(Boolean);

if (!files.length) {
  console.error('[check] 未找到 slide HTML（期望 courseware/**/slides/*.html）');
  process.exit(2);
}

// --- tiny static HTTP server (faithful relative asset loading) ----------------
const MIME = {
  '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.gif': 'image/gif', '.json': 'application/json', '.woff2': 'font/woff2', '.woff': 'font/woff',
  '.ttf': 'font/ttf', '.ico': 'image/x-icon',
};

function startServer() {
  return new Promise((res) => {
    const server = http.createServer(async (req, rep) => {
      let p = decodeURIComponent((req.url || '/').split('?')[0]);
      if (p === '/') p = '/index.html';
      const full = normalize(join(ROOT, p));
      if (!full.startsWith(ROOT)) { rep.statusCode = 403; return rep.end('403'); }
      try {
        const data = await readFile(full);
        rep.setHeader('Content-Type', MIME[extname(full).toLowerCase()] || 'application/octet-stream');
        rep.end(data);
      } catch {
        rep.statusCode = 404;
        rep.end('404');
      }
    });
    server.listen(0, '127.0.0.1', () => res(server));
  });
}

// --- main ---------------------------------------------------------------------
const server = await startServer();
const port = server.address().port;
const base = `http://127.0.0.1:${port}`;

// Launch: prefer Playwright's bundled chromium (CI installs it); fall back to system
// Google Chrome (e.g. local dev where the chromium download is blocked).
const launchArgs = ['--no-sandbox', '--disable-dev-shm-usage', '--allow-file-access-from-files'];
let browser;
try {
  browser = await chromium.launch({ args: launchArgs });
} catch (e1) {
  try {
    browser = await chromium.launch({ channel: 'chrome', args: launchArgs });
  } catch (e2) {
    console.error(`[check] 无法启动浏览器：${e2.message || e2}`);
    console.error('[check] 请运行 `npx playwright install chromium`，或安装系统 Google Chrome。');
    server.close();
    process.exit(2);
  }
}
const page = await browser.newPage();
page.setDefaultTimeout(20000);

const findings = [];

try {
  for (const file of files) {
    const rel = relative(ROOT, file);
    const url = `${base}/${rel.split('\\').join('/')}`;
    try {
      await page.goto(url, { waitUntil: 'domcontentloaded' });
      // wait for reveal.js to be ready
      await page.waitForFunction(
        () => window.Reveal && typeof window.Reveal.isReady === 'function' && window.Reveal.isReady(),
        { timeout: 15000 },
      );
      // best-effort: let initial images/fonts settle so heights are real, not pre-load
      await page.waitForLoadState('networkidle', { timeout: 5000 }).catch(() => {});
    } catch (e) {
      findings.push({ file: rel, slide: '—', heading: '(Reveal.js 未就绪/加载失败)', note: String(e && e.message) });
      continue;
    }

    const cfg = await page.evaluate(() => window.Reveal.getConfig());
    const slideW = cfg.width || 960;
    const slideH = cfg.height || 700; // slide canvas height — the clip threshold
    await page.setViewportSize({ width: slideW, height: slideH });
    await page.evaluate(() => window.Reveal.layout());

    // enumerate (h, v) of every slide in document order
    const coords = await page.evaluate(() => {
      const out = [];
      const tops = [...document.querySelectorAll('.slides > section')];
      tops.forEach((t, h) => {
        const verts = t.querySelectorAll(':scope > section');
        if (verts.length) [...verts].forEach((_, v) => out.push({ h, v }));
        else out.push({ h, v: 0 });
      });
      return out;
    });

    let slideNo = 0;
    for (const { h, v } of coords) {
      slideNo++;
      await page.evaluate(([hh, vv]) => window.Reveal.slide(hh, vv), [h, v]);
      // wait for this slide's images to finish loading (or fail) so the measured
      // height reflects real rendered content, not a pre-load stub
      await page.evaluate(async () => {
        const imgs = [...document.querySelectorAll('.slides section.present img')];
        await Promise.all(
          imgs.map((img) =>
            img.complete && img.naturalWidth > 0
              ? null
              : new Promise((res) => {
                  img.onload = () => res();
                  img.onerror = () => res();
                  setTimeout(res, 3000);
                }),
          ),
        );
      });
      await page.waitForTimeout(60);
      const m = await page.evaluate(() => {
        // reveal.js marks .present on BOTH the horizontal stack and the inner vertical
        // slide — pick the innermost (last in document order) = the actual visible slide.
        const presents = [...document.querySelectorAll('.slides section.present')];
        const s = presents[presents.length - 1];
        if (!s) return null;
        const hd = s.querySelector('h2, h1, h3, h4');
        return { sh: s.scrollHeight, heading: hd ? hd.textContent.trim().slice(0, 80) : '(无标题)' };
      });
      if (!m) continue;
      const limit = slideH + OVERFLOW_GRACE_PX;
      if (m.sh > limit) {
        findings.push({
          file: rel,
          slide: slideNo,
          heading: m.heading,
          scrollHeight: m.sh,
          slideHeight: slideH,
          overflowPx: m.sh - slideH,
        });
      }
    }
  }
} finally {
  await browser.close();
  server.close();
}

// --- report -------------------------------------------------------------------
if (asJson) {
  console.log(JSON.stringify({ overflow: findings, count: findings.length }, null, 2));
} else if (findings.length === 0) {
  console.log(`[check] ✅ 已扫描 ${files.length} 个 slide 文件，未发现超高溢出。`);
} else {
  console.log(`[check] ⚠️  发现 ${findings.length} 处 slide 超高溢出（底部内容会被 reveal.js 裁剪）：\n`);
  for (const f of findings) {
    if (f.note) {
      console.log(`  ${f.file} — ${f.heading}  (${f.note})`);
    } else {
      console.log(`  ${f.file} #${f.slide} 「${f.heading}」  内容高=${f.scrollHeight}px 画布高=${f.slideHeight}px 超出=${f.overflowPx}px`);
    }
  }
  console.log('\n[check] 修复建议：在对应 slide 的 markdown 里按语义插入 `---` 拆成多页（表格↔后续列表/引用；或长表按行对半拆并重复表头）。');
}

process.exit(findings.length ? 1 : 0);
