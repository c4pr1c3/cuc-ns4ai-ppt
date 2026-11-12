"""
含 AI 的靶场 Web 应用 —— 学生起点种子（capstone/seed/app.py）

本文件是渐进式作品 M0 的 fork 起点。它故意「最小可运行 + 预留攻击面」：
  - 基础鉴权/会话（M1 安全基线）
  - 一个【故意预留】的 SQL 注入点（M3 漏洞利用）
  - 一个 /api/agent 端点 + 工具白名单护栏钩子（M6 赋能 + 对抗）
  - 统一审计日志（M5 取证 / M6 检测组件挂钩处）

⚠️ 教学用途：包含【故意预留】的漏洞，仅供本课程授权环境使用。
   课程不教授编写恶意代码；所有测试仅限你自己的靶场。
"""

import sqlite3
import logging
import os
from functools import wraps
from flask import (Flask, request, session, jsonify, g)

app = Flask(__name__)
app.secret_key = "REPLACE_ME_WITH_A_SECURE_SECRET"  # M1：换成安全密钥

AUDIT = logging.getLogger("audit")
AUDIT.setLevel(logging.INFO)
# M5：把审计落到集中日志（此处简化为 stdout，作品里接 ELK/Suricata）
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

USERS = {"admin": "admin123", "alice": "password"}  # M1：换成密码哈希 + RBAC


# ---------------------------------------------------------------- auth
def login_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if "user" not in session:
            return jsonify({"err": "unauthorized"}), 401
        AUDIT.info(f"auth user={session['user']} path={request.path}")
        return fn(*args, **kwargs)
    return wrapper


@app.post("/login")
def login():
    u, p = request.form.get("u", ""), request.form.get("p", "")
    # M1：明文比对是【故意】的弱实现，M1 要你改成哈希 + 失败计数 + RBAC
    if USERS.get(u) == p:
        session["user"] = u
        AUDIT.info(f"login.success user={u}")
        return jsonify({"ok": True})
    AUDIT.info(f"login.fail user={u}")  # M6：AI 检测组件可挂这里做异常打分
    return jsonify({"err": "bad credentials"}), 401


# ---------------------------------------------------------------- M3 靶点
def db():
    if "db" not in g:
        con = sqlite3.connect("app.db")
        con.execute("CREATE TABLE IF NOT EXISTS orders "
                    "(id INTEGER PRIMARY KEY, user TEXT, item TEXT)")
        con.executemany("INSERT OR IGNORE INTO orders VALUES (?,?,?)",
                        [(1, "alice", "book"), (2, "alice", "flag-flag")])
        con.commit()
        g.db = con
    return g.db


@app.get("/orders")
@login_required
def orders():
    # ⚠️【故意预留】SQL 注入：拼接 user 到 SQL。M3 要你利用并修复（参数化）。
    user = request.args.get("user", session["user"])
    q = f"SELECT id, item FROM orders WHERE user = '{user}'"
    rows = db().execute(q).fetchall()
    return jsonify({"q": q, "rows": rows})


# ---------------------------------------------------------------- M6 AI 端点
# 工具白名单（M6 对抗侧的护栏核心）
ALLOWED_TOOLS = {"search", "get_order"}
DENY_TOOLS = {"email", "http_post", "rm"}  # 高危：须人在回路


def call_tool(name, arg):
    """M6：护栏。非白名单 → 人在回路；黑名单 → 直接拒绝。"""
    if name in DENY_TOOLS:
        AUDIT.warning(f"tool.blocked name={name}")
        return {"err": "denied"}
    if name not in ALLOWED_TOOLS:
        AUDIT.warning(f"tool.needs_human name={name}")
        return {"err": "needs human approval"}  # 人在回路（HITL）
    # 受信任工具的真实实现（此处仅占位）
    if name == "get_order":
        return db().execute("SELECT id,item FROM orders WHERE user=?",
                            (arg,)).fetchall()
    return {"ok": "search-stub"}


@app.post("/api/agent")
@login_required
def agent():
    """M6 赋能侧：一个带工具的 LLM 端点。
    对抗侧：间接注入/RAG 投毒/工具滥用会瞄准这里。
    学生需接入真实 LLM，并保留上面的护栏与审计。"""
    body = request.get_json(force=True)
    q = body.get("q", "")
    tool = body.get("tool")
    AUDIT.info(f"agent user={session['user']} q={q!r} tool={tool}")
    if tool:
        return jsonify({"tool_result": call_tool(tool, body.get("arg", ""))})
    return jsonify({"echo": "(接 LLM 后此处返回模型回答)"})


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "5000")), debug=False)
