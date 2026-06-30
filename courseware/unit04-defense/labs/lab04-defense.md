# Lab 04: 加固与边界防护（capstone M4）

> 📝 大纲。给被 M3 攻破的应用套上纵深防御，并度量误报/漏报。

## 1. 实验目标
- 能力交付（簇④·L2）：配置防火墙/WAF/IDS 规则 + 应用加固。

## 2. 环境准备
- 你的 M3 末应用；Snort/Suricata；iptables/nftables。

## 3. 任务清单（计划）
- 任务 A：防火墙规则（暴露面收敛）
- 任务 B：IDS 规则编写，验证能命中 M3 的攻击流量，度量 FPR/FNR
- 任务 C：WAF 拦截 SQLi/XSS 变种
- 任务 D：应用/运行环境加固（SSH、Web 服务器、容器）
- 进阶（为 M6 铺路）：叠加一个 Isolation Forest 异常打分

## 4. 交付与量规
- 绑定簇④·L2；规则集 + 命中/误报度量；tag `m4`。

## 5. 能力自评
- 簇④·L2：iptables/WAF/IDS 规则 ✅
