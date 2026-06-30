# Lab 03: Web 漏洞挖掘与利用（capstone M3）

> 📝 大纲。对自己的靶场应用（M1 末）发现并利用预设漏洞，写 PoC。⚠️ 仅在自己应用/授权环境。

## 1. 实验目标
- 能力交付（簇③·L2）：发现并利用 SQLi/XSS/上传/CSRF，每类写 PoC。

## 2. 环境准备
- 你的 M1 末应用（含 `capstone/seed` 预留的 `/orders` SQL 注入点）；Yakit/Burp/sqlmap。

## 3. 任务清单（计划）
- 任务 A：SQL 注入利用 + PoC（指向 `/orders?user=`）
- 任务 B：XSS（反射/存储）利用 + PoC
- 任务 C：文件上传漏洞利用
- 任务 D：CSRF 场景构造
- 任务 E（AI 赋能渗透·可选）：用 [PentestGPT](https://github.com/GreyDGL/PentestGPT) 跑一遍 M3 靶场，对比「AI 辅助 vs 人工」的效率与盲区；讨论 [flounder](https://github.com/adshao/flounder) / [Cairn](https://github.com/oritera/Cairn) 这类「自主漏洞挖掘 agent」的能力边界（**不替代**人工 PoC，仅作对比）

## 4. 交付与量规
- 绑定簇③·L2；每类 PoC + 复现步骤；tag `m3`。

## 5. 能力自评
- 簇③·L2：发现并利用 + PoC ✅
