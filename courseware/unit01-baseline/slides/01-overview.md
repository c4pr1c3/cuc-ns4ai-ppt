---
title: "第一单元: 安全基线"
subtitle: "【道·术·器·造器】 认证 · 会话 · RBAC · 网络基线"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# 主题 0：从「入门级漏洞」说起

---

## 问题引入：你的应用如何避免「入门级」漏洞？

> 每年泄露报告里排第一的，几乎不是零日漏洞（0day），而是**弱口令、明文会话、越权**——都不高级，但年年致命。

* M0 已做完威胁建模；**M1 把「基线安全」落到代码与配置上**
* 种子工程（seed）故意预留攻击面：`secret_key="REPLACE_ME"`(:21)、`USERS={admin:admin123}` 明文(:28)、`USERS.get(u)==p` 比对(:46)
* 本单元 = 关掉 M0 登记表的 **R1（弱口令）** 与 **R4（会话密钥）**

---

## 本单元地图（≤1 学时）：道 → 术 → 器 → 造器

1. **【道】**：认证 vs 授权、会话信任根、最小权限——三条安全观
2. **【术】**：口令哈希+盐 / 失败锁定 / 会话加固 / RBAC 行级授权
3. **【器】**：hashcat（攻击侧验证弱口令）/ flask-login（造器之前的器）
4. **【造器】**：落到你派生的应用 = 综合实践项目（capstone）**M1**

> 深度理论见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x03.md`。本课件只讲「做 M1 所需」。

---

## 能力框架对应

* 簇 ①「**安全基石与风险**」· **L3**（U1 把 U0 的 L1/L2 推到工程化）
* L1（U0）：复述 CIA/STRIDE/CVSS——**题库**
* L2（U0）：威胁建模 + 风险登记表——**M0**
* **L3（U1）：设计 RBAC / 风险登记表随项目演进 → 证据 M1**

> 本单元实验 = M1，证据就是你的「加固代码 + 种子工程弱实现 vs 新实现 加固对照表」。实验见 `labs/lab01-baseline.md`。

# 主题 1：【道】三条不变的安全观

---

## 认证 vs 授权：你是谁 ≠ 你能做什么

| | 认证（Authentication） | 授权（Authorization） |
| :-: | :- | :- |
| **回答** | **你是谁** | **你能做什么** |
| **失败后果** | 冒充（Spoofing，破坏认证属性） | 越权（Elevation，破坏授权属性） |
| **本单元对应** | 口令哈希 + 失败锁定（任务 A） | RBAC 行级授权（任务 C） |

> 混淆二者是常见根因：很多人把「登录成功」当成「可以做任何事」——种子工程的 `/orders` 正是只 `login_required`、无授权校验 → 越权可读他人订单。

---

## 会话信任根：拿到 cookie = 拿到你

* 登录成功后，服务器发一张**会话凭证（session cookie）**；之后所有请求**只凭这张凭证**认人
* 因此会话 = 第二个「**信任根**」（第一个是口令），它一旦被窃/被猜/被固定，认证就被绕过
* 三个常见致命点：
    * **secret_key 可猜/硬编码** → 攻击者可**伪造**任意会话（种子工程 :21 就是 `REPLACE_ME`）
    * **cookie 明文可读**（HTTP）/ **可被 JS 读取**（无 HttpOnly）→ 中间人/XSS 偷取
    * **会话不轮换**（登录后不 `regenerate`）→ 会话固定攻击

---

## 最小权限：默认 deny，allow 显式

* **最小权限原则**：每个主体只授予「完成任务所需的最小权限」，且**默认拒绝、显式允许**
* 落到代码：`/orders` 不能只问「你登录了吗」，要问「**这个 user 参数你是否有权读**」
* 落到角色：`admin` 能管账户、`alice` 只能读自己的单——**行级**而非端点级
* 这一条是 RBAC（任务 C）的灵魂，也是 M6 Agent 护栏（工具白名单）的同一思想

# 主题 2：【术】口令安全

---

## 不存明文：哈希 + 盐

* **绝不要**存明文口令（种子工程 :28 `USERS={admin:admin123}` 是反面教材）
* 存「**哈希值 + 随机盐**」：即便库被脱，攻击者也无法反推原口令
    * 盐 = 每用户一段随机串 → 相同口令哈希值不同，废掉彩虹表

> 原理（慢哈希、cost、pepper）见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x03.md`「口令安全」。

---

## 三种等价选型（择一，禁自造算法）

* `werkzeug.security.generate_password_hash(pw)` / `check_password_hash(hash, pw)` —— Flask 自带、最省事
* `bcrypt` —— 工业标准，可调 cost
* `pbkdf2` —— 标准库 / 通用框架常见


---

## 失败计数 + 锁定：让爆破「不划算」

* 仅哈希不够——在线爆破仍可穷举弱口令 → 加**失败计数 + 阈值锁定**
* 策略：连续失败 N 次（如 5）→ 锁账户 T 分钟（如 5）→ 提升单位攻击成本
* 落到 `/login`：失败累计、阈值后拒、成功/超时清零；**审计每条 `login.fail`**（种子工程 :50 留了钩子，M6 可挂 AI 打分）


# 主题 3：【术】会话加固

---

## Cookie 三件套：Secure / HttpOnly / SameSite

| 属性 | 防什么 | 配置 |
| :-: | :- | :- |
| **Secure** | 明文 HTTP 下被窃听 | 仅 HTTPS 发送 |
| **HttpOnly** | JS 读取（XSS 偷 cookie） | `document.cookie` 取不到 |
| **SameSite** | CSRF（跨站借 cookie 发请求） | `Lax`/`Strict` |


---

## Cookie 三件套：配置

```python
app.config.update(
    SESSION_COOKIE_SECURE=True,      # 生产须 HTTPS
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
)
```

---

## 过期 + 防固定（会话加固）

* **过期**：`session.permanent=True` + `PERMANENT_SESSION_LIFETIME` 设上限——会话不能永久有效
* **防会话固定**：登录成功 / 权限变更时 `session.regenerate()`（清旧 sid、发新的），防止攻击者预植的 sid 被受害者登录后复用

---

## 随机化 secret_key（闭环 M0 R4）

* 种子工程 :21 的 `REPLACE_ME` 让签名可预测 → 改用 `secrets.token_hex(32)` 启动时随机化（**闭环 M0 R4**）

```python
import secrets
app.secret_key = secrets.token_hex(32)   # 不再硬编码，落实 M0 R4
```

> 这是 M0 登记表 R4 的「落到代码」证据——评审会专门看 `secret_key` 是否仍硬编码。

# 主题 4：【术】RBAC 授权

---

## 角色模型 + 行级授权：从「能进」到「能做哪一行」

* **角色模型**：`admin` / `alice` 各自能做什么——一张角色-权限矩阵
* **端点级**：用装饰器把端点绑到角色，如 `@rbac_required("admin")`
* **行级（本单元重点）**：`/orders` 等「带参数查资源」端点，**必须服务端强校验 `user` 参数**

> 种子工程 `/orders` 直接信任前端传的 `user` → 越权读他人订单（M3 SQLi 之外的另一个必修点）。

---

## `@rbac_required` 装饰器（端点级实现）

```python
def rbac_required(role):
    def deco(fn):
        @wraps(fn)
        def w(*a, **k):
            u = session.get("user")
            if not u or USERS_ROLE.get(u) != role:
                return jsonify({"err": "forbidden"}), 403
            return fn(*a, **k)
        return w
    return deco
```

---

## `/orders` 行级授权：服务端不信任何客户端入参

* 反例（种子工程 :71）：`user = request.args.get("user", session["user"])` → 前端传谁的 `user` 就查谁
* 正解：**服务端强校验**——`user` 只能取自 `session["user"]`（或显式比对 `user == session["user"]`），否则 403
* 默认 deny、显式 allow：宁可误拒，不可误放
* 这条同时挡住「水平越权」（同级读他人）与「垂直越权」（普通用户碰到 admin 端点）

# 主题 5：【器】工具与「造器」的分野

---

## 【器】hashcat（攻击侧）+ flask-login（防御侧）

* **hashcat**（攻击侧）：离线爆破哈希——用**你脱下来的自己的库**验证「弱口令到底有多弱」，是 M1 的**自检**手段
    * 例：把 `admin` 的哈希丢进 hashcat + 字典，秒级还原 `admin123` → 这就是为什么不能有弱口令
* **flask-login**（防御侧）：成熟的会话/登录管理库，封装了「记住我、会话加载、登出」等

> ⚠️ 这是「**用器**」——会调库、会跑工具只是开始。**课程目标是「造器」**：理解口令为何要加盐、会话为何要轮换、授权为何要行级，进而能设计**带 AI 能力的**认证与护栏（M6）。

---

## hashcat 自检：验证你的口令策略是否真的够强

```bash
# 生成一个测试哈希（自造、可逆、仅自检）
echo -n "admin123" | sha256sum
# 用字典模式爆破（仅对你自己的哈希、在授权环境内）
hashcat -m 1400 -a 0 myhash.txt rockyou.txt
```

* 若秒级还原 → 你的口令策略太弱（即便加了盐）→ 倒逼提高最小长度/复杂度、加失败锁定
* **红线**：仅对你**自己脱下来的、自己应用里的**哈希做；**禁止**对他人/真实系统

> 这是「侦察可逆」的同一思想：攻击者能爆的，你理应先自爆出来。

# 主题 6：【造器】衔接实验 M1

---

## 加固对照表（1/2）：口令 · 登录 · secret_key

| 维度 | 种子工程弱实现 | M1 新实现 | 闭环 |
| :-: | :- | :- | :- |
| 口令 | `USERS={admin:admin123}` 明文(:28) | `generate_password_hash` + 盐 | **R1** |
| 登录 | `USERS.get(u)==p` 明文比对(:46) | `check_password_hash` + 失败锁定 | R1 |
| secret_key | `REPLACE_ME` 硬编码(:21) | `secrets.token_hex(32)` | **R4** |

---

## 加固对照表（2/2）：cookie · 授权

| 维度 | 种子工程弱实现 | M1 新实现 | 闭环 |
| :-: | :- | :- | :- |
| cookie | 无三件套 | Secure/HttpOnly/SameSite + 过期 | — |
| 授权 | 仅 `login_required` | `@rbac_required` + 行级校验 | — |

> 这张表是 `docs/m1/report.md` 的核心——**逐条对照、附测试佐证**，体现 L3「工程化」而非「贴配置」。

---

## 任务全景（A→E）

```
任务 A 口令哈希 + 失败计数 / 锁定        ── 闭环 R1
任务 B 会话加固（cookie 三件套 + 过期 + 防固定 + 随机 secret）── 闭环 R4
任务 C RBAC（角色 + @rbac_required + /orders 行级授权）
任务 D 网络 / 传输基线（暴露面收敛 + HTTPS 思路 + iptables）
任务 E（可选）AI 辅助审查加固配置、生成对照表草稿
```

* 起点分支：`milestone/m1`（从 `milestone/m0` 切，**不是 main**），开 MR 目标 = `milestone/m0`
* 自检命令：`git grep -nE 'generate_password_hash|bcrypt|pbkdf2'` / `'secrets.token'` / `'fail.*count|lock'`

# 主题 7：网络基线（任务 D 速览）

---

## 暴露面收敛 + HTTPS：纵深防御的一层

* **暴露面收敛**：关多余端口/服务——只暴露 5000（或反代后 443）；U2 会专门量化
* **传输加密**：反代 + 证书（自签用于实验，生产用 Let's Encrypt / ACME）
* **主机防火墙**：`iptables` / `nftables` 写收敛规则——**默认 DROP、显式 ACCEPT**

```bash
# 仅放行 22 / 5000，其余入站默认拒绝（仅本机授权环境）
sudo iptables -A INPUT -p tcp --dport 22   -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
sudo iptables -P INPUT DROP                  # 默认 deny
```

# 主题 8：能力自评与红线

---

## 本单元点亮簇 ①·L3（安全工程化）

| 级 | 能力描述 | 自评勾选 |
| :-: | :- | :-: |
| L1 | 复述 CIA/STRIDE/CVSS，识别资产与威胁 | ☐ U0 已点亮 |
| L2 | 对系统做威胁建模 + 风险登记表 | ☐ M0 已点亮 |
| **L3** | **设计并实现 认证/会话/RBAC + 网络基线，并随项目演进** | ☐ **M1 交付** |

* 自评须与作品一致（**无虚点亮**）：在 `docs/m1/report.md` 逐项附证据路径
* 评审专门看：R1（口令）与 R4（secret_key）是否真闭环、RBAC 是否有行级授权

---

## ⚠️ 红线：仅对授权环境

* 所有加固/爆破实验**仅在自己派生的靶场、`127.0.0.1` 或明确授权的环境内**
* hashcat 等工具只对你**自己**脱下来的哈希做——**禁止**对任何真实/第三方系统
* 课程**不教授**编写恶意代码；基线工具同时是**防御自查**手段

---

## 小结与下一单元

1. **道**：认证 ≠ 授权；会话是第二信任根；最小权限默认 deny
2. **术**：口令哈希+盐+失败锁定 / cookie 三件套+防固定+随机 secret / RBAC 行级授权
3. **造器**：把种子工程的明文弱实现改成加固版，逐条对照 → **M1**

> 下一单元 **U2 自侦察（M2）**：对你这版「**已加固**的应用」做暴露面测绘——你能看见自己暴露了什么，攻击者就能看见什么。
