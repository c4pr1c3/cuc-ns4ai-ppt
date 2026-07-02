# 精选高质量参考链接（国产优先 · 道术器标注）

> 课程《网络安全（AI 时代版)》分单元精选参考。每条标 [道]/[术]/[器] + 为何推荐 + 访问日期（2026-06）。
> **国产优先**：有国产替代处首选国产（蜜罐 HFish、大模型 DeepSeek/Qwen/GLM/Kimi）；国际标准（CVSS/OWASP/MITRE）无国产替代，引用官方一手源。课程禁止选用国外大模型（GPT/Claude/Gemini）作为接入模型。

## U0 · 立项与威胁建模（M0，簇①）
- 【道/术】**STRIDE 威胁建模** — Microsoft SDL Threat Modeling: https://learn.microsoft.com/en-us/azure/architecture/guide/security/security-threat-modeling （STRIDE 六类权威出处）
- 【道/术】**CVSS v3.1 标准** — FIRST.org: https://www.first.org/cvss/v3-1/ ；计算器: https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator （评分唯一权威源，向量可追溯）
- 【器】**OWASP Cheat Sheet Series** — https://cheatsheetseries.owasp.org/ （各漏洞防御速查）

## U1 · 安全基线（M1，簇①）
- 【道/术】**OWASP Authentication Cheat Sheet** — https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- 【术】**口令哈希（bcrypt/argon2）** — https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
- 【器】**hashcat**（攻击侧验证弱口令）— https://hashcat.net/wiki/

## U2 · 自侦察（M2，簇②）
- 【道/术】**nmap 官方文档** — https://nmap.org/book/ （SYN/Connect/UDP/指纹原理权威）
- 【器】**Wireshark / tshark** — https://www.wireshark.org/docs/wsug_html_chunked/
- 【器】**NVD 漏洞库**（版本→CVE）— https://nvd.nist.gov/

## U3 · 漏洞挖掘与利用（M3，簇③）
- 【道/术】**PortSwigger Web Security Academy** — https://portswigger.net/web-security （SQLi/XSS/CSRF/上传 一手实训，免费）
- 【道/术】**OWASP Top 10** — https://owasp.org/www-project-top-ten/
- 【器】**sqlmap** — https://github.com/sqlmapproject/sqlmap/wiki/Usage

## U4 · 加固与边界防护（M4，簇④）
- 【道/术】**纵深防御** — OWASP Security by Design / NIST SP 800-53 思路
- 【术/器】**OWASP CRS（ModSecurity 规则集）** — https://coreruleset.org/
- 【术/器】**Suricata IDS** — https://docs.suricata.io/ ；**Snort** — https://www.snort.org/documents

## U5 · 日志·取证·蜜罐（M5，簇⑤）
- 【道/术】**MITRE ATT&CK** — https://attack.mitre.org/ （攻击链/IoC 思维框架）
- 【术/器】**ELK / Elastic Security** — https://www.elastic.co/guide/ （集中日志）
- 【器·国产】**HFish 蜜罐**（国产，推荐）— https://github.com/hacklcx/HFish ；对照 Cowrie https://github.com/cowrie/cowrie

## U6 · AI 赋能与对抗（M6，簇⑥·核心）
- 【道】**OWASP LLM Top 10** — https://owasp.org/www-project-top-10-for-large-language-model-applications/
- 【道】**MITRE ATLAS**（AI 系统攻击知识库）— https://atlas.mitre.org/
- 【道】**NIST AI RMF Generative AI Profile** — https://www.nist.gov/itl/ai-risk-management-framework
- 【术/器·国产】**国产大模型（课程唯一允许的接入模型）**：
  - DeepSeek — https://www.deepseek.com/ （OpenAI 兼容协议）
  - Qwen（通义千问）— https://github.com/QwenLM/Qwen2
  - GLM（智谱）— https://open.bigmodel.cn/
  - Kimi（Moonshot）— https://platform.moonshot.cn/
- 【术】**scikit-learn IsolationForest** — https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html （AI 检测组件）

## U7 · 红蓝对抗 + 复盘（M7，全簇）
- 【道/术】**GenAI Red Teaming Guide** — https://github.com/requie/AI-Red-Teaming-Guide
- 【术】**紫队/复盘方法论** — 参考 ATT&CK Evaluations + 课程内部复盘模板

## 工程基础（全单元）
- 【器】**Git** — https://git-scm.com/book/zh/v2 （中文 Pro Git）
- 【器】**GitLab CI/CD** — https://docs.gitlab.com/ee/ci/ ；**python-gitlab** — https://python-gitlab.readthedocs.io/
- 【器】**reveal.js**（课件渲染）— https://revealjs.com/

> 维护：链接每学期开课前复核（标注访问日期）；失效即换一手源；新增国产工具优先收录。
