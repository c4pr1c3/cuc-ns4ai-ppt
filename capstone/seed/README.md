# 渐进式作品 · 种子工程（学生 fork 起点）

> 这是《网络安全（AI 时代版）》渐进式作品 M0 的起点脚手架。fork 它，按 [`overview`](../overview.md) 的 M0-M7 在**同一个仓库**里持续迭代。

## 最小可运行

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python app.py          # 监听 127.0.0.1:5000
```

## 预留的「教学锚点」（对应里程碑）

| 文件/位置 | 锚点 | 里程碑 |
| :- | :- | :-: |
| `app.py` `/login` | 弱口令 + 明文比对 | M1 安全基线 |
| `app.py` `/orders` | **故意预留 SQL 注入**（字符串拼接） | M3 漏洞利用 |
| `app.py` `call_tool` | 工具白名单 + 黑名单 + 人在回路钩子 | M6 对抗加固 |
| `app.py` `/api/agent` | 带工具的 LLM 端点（接真实模型） | M6 赋能+对抗 |
| `AUDIT` 日志 | 统一审计出口 | M5 取证 / M6 检测 |

## 迭代约定

- 每个里程碑开一个分支：`milestone/m0`, `milestone/m1`, … `milestone/m7`（**不打 tag**）。分支首尾相接——`milestone/m{n}` 基于 `milestone/m{n-1}` 切出（M0 基于 `main`）。
- 每个里程碑提一个 **Merge Request**：源 = `milestone/m{n}`，目标 = 上一里程碑分支（M0 目标 `main`）；**@ 助教** 通知批改；**保持 Open、不合并、不关闭**。
- 每次提交附里程碑报告（做了什么 / 点亮哪些能力簇 / 踩到的坑）。
- ⚠️ 所有攻击实验**仅在本仓库自己的应用、授权环境**内进行；课程不教授编写恶意代码。
- 完整 Git 操作规范见 [`Git 指南`](../../courseware/unit00-intro/labs/git-guide.md)；一键开里程碑分支：`bash scripts/new-milestone.sh <n>`。

## 你需要自己补的（按里程碑）

- M1：密码哈希、失败计数、RBAC、安全会话
- M2：侦察脚本（端口/服务/指纹）、暴露面清单
- M3：对 `/orders` 等写 PoC，然后修复（参数化）
- M4：WAF/防火墙/IDS 规则、加固
- M5：集中日志、取证 playbook、蜜罐
- M6：接真实 LLM；加 AI 检测组件（`sklearn`）；做注入/RAG 投毒 PoC；加护栏
- M7：红蓝对抗、取证报告、能力自评矩阵
