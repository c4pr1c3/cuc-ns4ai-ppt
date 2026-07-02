---
title: "第二单元: 侦察自动化"
subtitle: "监听 · 扫描 · 指纹 · OSINT"
author: 黄玮
date: 2026-秋
output: revealjs::revealjs_presentation
---

# 主题 0：攻击者如何踩点？

---

## 问题引入：攻击前置 = 侦察

> 攻击者动手前，**第一件事永远是「看清你」**——你开了哪些口、跑了什么服务、用了什么版本、谁是可以骗的人。

* 侦察（Reconnaissance）= 杀伤链第一步：**收集 → 加工 → 自动化**
* 防御视角同样适用：**你能看见自己暴露了什么，攻击者就能看见什么**
* 本单元 = 给你的靶场应用做一次「**自侦察**」（综合实践项目（capstone）**M2**）

---

## 本单元地图（≤2 学时）：监听 · 扫描 · 指纹 · 自动化

1. 网络监听：原理（混杂模式）+ ARP 欺骗直觉 + Wireshark
2. 网络扫描：TCP/UDP/ICMP 扫描直觉 + **nmap** 核心用法
3. 服务/OS 指纹识别（`-sV` / `-O`）
4. 自动化：把扫描脚本化 → **结构化暴露面清单**

---

## 本单元地图（≤2 学时）：社工 · AI · 防御

5. 社会工程与 OSINT（人是最弱环节）
6. AI-OSINT（可选埋伏，呼应 U6）
7. 防御视角：发现自己的暴露面（= 实验）

> 深度理论（ARP 报文结构、TCP 状态机、端口状态全集）见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x04.md` / `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x05.md`。本课件只讲「做 M2 所需」。

---

## 能力框架对应

* 簇 ②「**侦察与发现**」· **L1 / L2 / L3**（U2 是少数三级全在本单元的能力簇）
* L1：解释监听/扫描原理与指纹识别（**题库**）
* L2：用 Wireshark/nmap 完成测绘并出报告（**M2**）
* L3：编写**可复用侦察脚本** + 暴露面清单治理（**M2** 脚本交付）

# 主题 1：网络监听

---

## 监听的本质：让网卡「偷听」不属于自己的流量

* 正常网卡：**只接收目标 MAC = 自己**的帧（单播/广播）
* **混杂模式（promiscuous）**：接收链路上**所有**帧 → 监听的基础
* 监听位置决定能听到什么：
    * **共享式（Hub / 无线）**：天然广播，混杂模式即可全收
    * **交换式（Switch）**：端口隔离，**默认听不到别人的流量** → 需要「主动监听」

> 监听是**被动**的：只看，不发。因此**极难被远端检测**——这也是它危险的原因。

---

## 交换式网络：ARP 欺骗（直觉版）

* 交换机靠 **MAC 表**转发；主机靠 **ARP 缓存**（IP→MAC）发包
* **ARP 欺骗（ARP Spoofing / 中间人）**：攻击者**持续广播伪造的 ARP 应答**
    * 告诉受害者「网关的 MAC 是我」
    * 告诉网关「受害者的 MAC 是我」
    * 流量被「绕」到攻击者 → 转发 + **监听**（中间人）

---

## ARP 欺骗：防御直觉

* **静态 ARP 绑定** / **DHCP Snooping + DAI** / **检测 IP-MAC 异常映射**

> 报文级细节（GARP、 gratuitous ARP、检测脚本）见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x04.md`「主动监听」「检测 ARP 缓存投毒者」。

---

## Wireshark 实战要点（捕获与过滤）

```bash
# 列出可捕获网卡
sudo tshark -D
# 只抓指定主机的流量，存盘
sudo tshark -i eth0 -f "host 127.0.0.1" -w m2.pcapng
```

* **捕获过滤器**（`-f`，BPF 语法，抓前过滤）：`host X`、`tcp port 80`、`net 10.0.0.0/24`
* **显示过滤器**（抓后过滤）：`http`、`tcp.port==5000`、`ip.addr==127.0.0.1 && http.request.method==POST`

---

## Wireshark 实战：分析三件套

* **Follow TCP Stream**（还原会话）· **右键作为过滤器应用** · **统计 → 协议分级**

> **M2 提示**：跑起你的 Flask 靶场后，用 Wireshark 抓一次登录/查询，能直接看到 **明文凭证、SQL 语句**——这是「监听能暴露什么」的最直观证据。

# 主题 2：网络扫描

---

## 监听 vs 扫描

| | 监听（被动） | 扫描（主动） |
| :-: | :- | :- |
| **动作** | 只收，不发 | **主动发包**，看回应 |
| **目标** | 还原链路上已有流量 | 探测「**谁在、开了什么口**」 |
| **隐蔽性** | 高（被动） | 低（留日志、易被 IDS 发现） |
| **代表工具** | Wireshark / tcpdump | **nmap** |

* 扫描回答三件事：**主机是否存活**、**哪些端口开放**、**端口后是什么服务/版本**

---

## 扫描直觉：TCP 扫描（SYN / Connect）

* **TCP SYN 扫描（半开，`-sS`）**
    * 发 `SYN` → 收 `SYN/ACK` = **开放**；收 `RST` = 关闭；无回应 = 被过滤
    * **不完成三次握手** → 不留应用层日志，**nmap 默认、最快、最隐蔽**
* **TCP Connect 扫描（`-sT`）**
    * 完整三次握手；**无需 root**，但目标应用会记下连接 → 易被发现

---

## 扫描直觉：UDP / ICMP 扫描

* **UDP 扫描（`-sU`）**
    * UDP 无连接：有回 ICMP `port unreachable` = 关闭；无回应 = **open|filtered**（不确定）
    * **慢且不可靠**，但对 DNS/SNMP 等服务必需
* **ICMP 扫描（Ping，`-sn`）**：判断主机存活（注意防火墙常禁 ICMP）

> TCP/UDP/ICMP 协议复习与端口状态全集见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x05.md`「网络扫描原理」。

---

## 【道】UDP 扫描为何又慢又不可靠

* **无连接**：UDP 不像 TCP 有握手，端口开/关都得靠 ICMP 反推
* **速率受限**：为区分「开放」与「被防火墙过滤」，nmap 必须慢速重传 + 等超时 → 默认比 TCP 慢一个量级
* **丢包无重传**：UDP 本身不重传，丢包即误判为 `open|filtered` → 结果噪音大
* 实操：扫 UDP 要 `-sU --max-retries 1` + 耐心，或只扫已知 UDP 服务（53 DNS / 161 SNMP）

---

## nmap 核心用法（命令速查）

```bash
# 主机发现（谁活着）——对单机/本机也可
nmap -sn 127.0.0.1

# TCP SYN 扫描 + 指定端口范围（需 root）
sudo nmap -sS -p- 127.0.0.1          # -p- = 全部 65535 端口

# 服务/版本探测 + 默认脚本 + OS 指纹 = "-A" 综合体检
sudo nmap -A 127.0.0.1
# 等价于分项：
sudo nmap -sV -sC -O 127.0.0.1       # -sV 版本 -sC 默认脚本 -O OS指纹

# 输出结构化结果，供脚本消费
sudo nmap -sS -sV -p- 127.0.0.1 -oX m2-scan.xml    # XML
nmap -sV -p 1-1000 127.0.0.1 -oG m2-scan.grep      # grep 友好
```

---

## nmap 常用 flag 速记

* `-sS`（SYN）/ `-sT`（Connect）/ `-sU`（UDP）/ `-sn`（只 Ping）
* `-p-`（全端口）/ `-p 22,80,5000`（指定）/ `--top-ports 100`
* `-sV`（版本）/ `-O`（OS）/ `-A`（综合）/ `-sC`（脚本）
* `-oX` / `-oG` / `-oN` / `-oA`（全格式）：**脚本化的关键**

# 主题 3：指纹识别

---

## 为什么「指纹」是侦察的高价值产出（服务 / OS）

* 知道「**开了口**」不够，要知道「**口后是什么、什么版本**」→ 版本决定可利用漏洞
* **服务指纹（`-sV`）**：根据 Banner / 协议探针识别服务与版本
    * 例：`5000/tcp open http` → `-sV` → `5000/tcp open http Werkzeug httpd 3.0.x (Flask)`
* **OS 指纹（`-O`）**：根据 TCP/IP 协议栈实现差异（窗口大小、选项顺序…）猜操作系统

---

## Web / 应用指纹

* `http-title`、`http-server-header`、响应头 `Server`/`X-Powered-By`、favicon hash、页面特征

> **M2 提示**：对你的 Flask 靶场做 `-sV`，会暴露 `Werkzeug`/`Python` 版本——这正是攻击者后续（U3）选漏洞利用 payload 的依据。

---

## 【术】指纹伪装：让攻击者扫不准（呼应 U4 加固）

* **改响应头**：`Server`/`X-Powered-By` 改名/去版本；统一错误页（去掉 Werkzeug 调试栈）
* **前置 WAF/反向代理**：Nginx/ModSecurity 层统一 `Server` 头，隐藏后端真实栈
* **指纹对抗是双向的**：攻击者用 favicon hash / 时序侧信道反推，防御者改默认值 + 加噪
* 伏笔：M4 会把这些做成**规则**（WAF 拦截 + 指纹隐藏 = 纵深防御）

# 主题 4：自动化侦察

---

## 从「手动敲」到「脚本化」：为什么必须自动化

* 手动 `nmap` 一次 = 一份报告；**每次部署变更都要重测**
* 自动化 = 把「**发现 → 指纹 → 清单**」串成**可复用脚本**，产出**结构化暴露面清单**
* 这是簇 ② · **L3**（工程化）的核心要求：不只是「会做一次」，而是「**能造、能持续**」

---

## 最小可用侦察脚本（bash 版）

```bash
#!/usr/bin/env bash
# recon.sh —— 对自己的靶场做一次自侦察，产出暴露面清单
# ⚠️ 仅对 127.0.0.1 / 你自己授权的靶场使用
set -euo pipefail
TARGET="${1:-127.0.0.1}"
OUT="recon-$(date +%Y%m%d-%H%M).txt"

echo "=== 主机发现 ==="             | tee "$OUT"
nmap -sn "$TARGET"                  | tee -a "$OUT"
echo "=== 全端口 SYN + 版本探测 ===" | tee -a "$OUT"
sudo nmap -sS -sV -p- "$TARGET" -oA "recon-${TARGET}" | tee -a "$OUT"
echo "=== 暴露面清单已写入 $OUT ==="
```

---

## 进阶：用 Python 解析 nmap XML（遍历主机与端口）

```python
# parse_nmap.py —— 把 nmap -oX 的结果解析为结构化暴露面清单
import xml.etree.ElementTree as ET
import sys, json

def parse(path):
    tree = ET.parse(path); root = tree.getroot()
    surfaces = []
    for host in root.findall("host"):
        addr = host.find("address").get("addr")
        for port in host.findall(".//port"):
            sid = port.find("portid").text
            st  = port.find("state").get("state")
            svc = port.find("service")
            surfaces.append(_row(addr, sid, st, svc))
    return surfaces
```

---

## 进阶：用 Python 解析 nmap XML（结构化 + 运行）

```python
def _row(addr, sid, st, svc):
    return {
        "host": addr, "port": sid, "state": st,
        "service": svc.get("name") if svc is not None else "",
        "product": svc.get("product") if svc is not None else "",
        "version": svc.get("version") if svc is not None else "",
    }

if __name__ == "__main__":
    print(json.dumps(parse(sys.argv[1]), ensure_ascii=False, indent=2))
```

> 亦可 `pip install python-nmap` 用封装库。**L3 的关键不是用哪种语言，而是产出「可被下次工程消费」的结构化数据**。

# 主题 5：社会工程与 OSINT

---

## 人是最弱环节（第 13 章并入）

> 花几天攻破防火墙，不如打一个电话让员工自己把密码交出来。——经典社工直觉

* **社会工程学**：利用「**人的心理**」（信任、权威、紧迫、贪婪）绕过技术防御
* 常见手段：**钓鱼（Phishing）**、**水坑攻击**、**尾随/窥视**、**垃圾搜索**、**反向社工**

---

## OSINT（公开来源情报）

* **OSINT（公开来源情报）**：从公开渠道收集目标信息
    * 域名/子域、Whois、搜索引擎（Google Dork）、GitHub 泄露、社工库、社交网络画像

> 仅取 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/chap0x13.md`「社会工程学与网络钓鱼」一节；社交网络谣言/营销/电信诈骗不在本单元范围。

---

## 防御直觉

* **人**：安全意识培训、钓鱼演练、最小信任、核实再行动
* **信息**：减少公开暴露（关闭目录列举、清理过期页面、`robots.txt`/敏感接口下线）
* **流程**：凭证不随意外发、变更通过带外渠道二次确认

# 主题 6：AI-OSINT（可选埋伏）

---

## AI 加速情报整理（呼应 U6）

* 大量 OSINT 原始数据（截图、网页、子域列表）→ **AI 做归纳、分类、关联、画像**
* **攻击侧**：AI 让钓鱼文案更逼真（深度伪造语音/邮件）、让暴露面归因更快
* **防御侧**：AI 自动审视己方公开足迹，**提前发现「我没想到会暴露的东西」**

---

## ⚠️ 埋伏：AI-OSINT 结论需审查

* U6 会系统讲「**AI 作为对象**」——AI 工具本身也会被投毒/误导，OSINT 结论需审查，不可盲信

> 本页为可选，不作为 M2 必交项；感兴趣见 `https://github.com/c4pr1c3/cuc-ns-ppt/blob/master/llm-security.md`。

# 主题 7：防御视角

---

## 侦察可逆：用攻击者的方法审视自己

* 攻击者能扫到的，你**理应先扫到**——这就是「**自侦察**」的价值
* 把每次自侦察结果纳入**暴露面清单治理**：
    * 该关的端口关了吗？（最小暴露）
    * 版本是否过时、有无已知 CVE？（升级/打补丁）
    * 指纹信息是否过度暴露？（隐藏 Banner、统一错误页）
    * 有没有「我以为是内网、其实对外」的服务？（配置漂移）
* **持续化**：把 `recon.sh` 接进 CI，每次部署后自动跑 → 暴露面**可追溯、可治理**
* 这正是 M2 从「L2 测绘」走向「L3 工程化」的分水岭

# 主题 8：能力自评

---

## 本单元点亮簇 ②「侦察与发现」

| 级 | 能力描述 | 自评勾选 |
| :-: | :- | :-: |
| **L1** | 能解释监听/扫描原理与指纹识别 | ☐ 题库达标 |
| **L2** | 用 Wireshark/nmap 完成测绘并出报告 | ☐ M2 测绘完成 |
| **L3** | 编写**可复用侦察脚本** + 暴露面清单治理 | ☐ M2 脚本+清单交付 |

---

## ⚠️ 红线：仅对授权环境

* 所有扫描/监听**仅对自己的靶场、自己的应用、127.0.0.1 或明确授权的环境**
* **禁止**对任何真实/第三方系统做未授权探测（即便「只是看看」）
* 课程**不教授**对他人系统的攻击；本单元工具同时是**防御自查**手段
