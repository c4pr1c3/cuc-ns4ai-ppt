# CI 指南：给自己的作业仓库装上 gitlab-runner

> 配套：[Git 操作指南](git-guide.md) · [综合实践项目总览](../../../capstone/overview.md) · [实验 00 / M0](lab00-threat-model.md)
> 适用对象：想让每次提交都带一份「自动构建/自检日志」的同学。环境示例：**Ubuntu 22.04 Server**（虚拟机即可）。

---

## 1. 为什么值得花这半小时

- **动态证据**：实验报告写的是「我做了什么」，CI 日志证明「它真的能跑」。每次 `git push` 都会自动执行仓库里的 `demo.sh` 一键自检，GitLab 留下带时间戳的构建日志——助教（含 AI 助教）评审时会核对你被评提交的流水线（pipeline）状态和日志，实验报告的「动态执行效果」不靠嘴说。
- **独立完成的客观证据链**：一整个学期的 commit 时间线 + 逐次构建日志 + 你自己服务器上的 runner 执行环境，构成一条很难事后伪造的连续记录。原创作者随手就能拿出这套证据；临时拼凑或抄袭来的仓库，补不出这样的过程痕迹。
- **即时反馈**：改坏了立刻红，不用等评审才发现 `demo.sh` 跑不通。

> 实在没有条件跑 runner 也不致命：保证 `.gitlab-ci.yml` 语法合法、本地 `bash demo.sh` 退出码为 0，并在 `report.md` 里注明本地自检结果，评审时有对应的降级核验口径。但有真实构建日志的同学，证据链完整度就是高一档。

---

## 2. 工作原理一句话

你 `git push` → 课程 GitLab 生成 pipeline → 把构建任务（job）派给**你自己机器上的 gitlab-runner** → runner 执行 `.gitlab-ci.yml` 里的脚本（装依赖、跑 `demo.sh`）→ 日志与结果回传 GitLab，显示在 commit、MR 和 `Build → Pipelines` 页面上。

Runner 装在你自己控制的 Ubuntu 机器上，只接你自己仓库的活。

---

## 3. 前置条件

- 一台 Ubuntu 22.04 Server（虚拟机即可），有 sudo 权限，能访问 `https://git.cuc.edu.cn`
- 已在课程 GitLab 上派生了自己的作业仓库
- 你在作业仓库上的角色是 **Maintainer**——创建和管理 runner 的最低角色要求是 Maintainer，`Developer` 在仓库左侧看不到 `Settings` 菜单。如果没有 `Settings`，联系助教提权后再继续
- 磁盘空闲 ≥ 2 GB（选 docker 执行器建议 ≥ 5 GB）

---

## 4. 安装 gitlab-runner

两种方式二选一，校园网推荐方式 A（清华镜像）。

### 方式 A：清华 TUNA 镜像（推荐）

```bash
# ① 导入 GitLab 官方 GPG 公钥
curl -L https://packages.gitlab.com/runner/gitlab-runner/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/gitlab-runner.gpg

# ② 写入镜像源（Ubuntu 22.04 的代号是 jammy）
echo "deb [signed-by=/usr/share/keyrings/gitlab-runner.gpg] https://mirrors.tuna.tsinghua.edu.cn/gitlab-runner/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/gitlab-runner.list

# ③ 安装
sudo apt update && sudo apt install -y gitlab-runner
```

### 方式 B：官方仓库一键脚本

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
less script.deb.sh    # 好习惯：curl 下来的脚本先看内容再执行
sudo bash script.deb.sh
sudo apt install -y gitlab-runner
```

验证安装：

```bash
gitlab-runner --version
sudo gitlab-runner status    # 应显示服务正在运行
```

---

## 5. 在 GitLab 上创建 runner 并拿到令牌

1. 打开**你自己的作业仓库**，左侧 `Settings → CI/CD → Runners`，点 `New project runner`。
2. 勾选 **`Run untagged jobs`**——本课程的 `.gitlab-ci.yml` 不给 job 打标签（tag），不勾的话 runner 永远接不到活。
3. 其余保持默认，点 `Create runner`，页面会给出一枚 `glrt-` 开头的认证令牌（authentication token）。**它只显示这一次**，立即保存到本地安全的地方（例如密码管理器），**绝不能提交进仓库**。

> 如果你看到的是旧版界面（给的是 registration token 而不是上面的新建流程），在 `Runners` 展开区找到 registration token，下一步注册命令改用 `--registration-token` 参数。

---

## 6. 注册 runner 到你的机器

```bash
sudo gitlab-runner register --url https://git.cuc.edu.cn --token glrt-你的令牌
```

交互提问这样答：

- `description`：随意，如 `my-ubuntu2204`
- `executor`：填 `docker`（推荐）或 `shell`——两者区别见 §7
- 选了 docker 还会问默认镜像：填 `python:3.11-slim`

验证：回到 GitLab 的 `Runners` 页面，你的 runner 前面应是绿色圆点；本机执行 `sudo gitlab-runner verify` 应输出 `is alive`。

---

## 7. 两种执行器（executor）怎么选

| | `docker`（推荐） | `shell`（备选） |
| :- | :- | :- |
| 隔离性 | 每个 job 一个干净容器，不碰你的系统 | 直接跑在你的系统上 |
| `.gitlab-ci.yml` 的 `image:` 字段 | 生效（`python:3.11-slim`） | 被忽略，用本机 `python3` |
| 额外依赖 | 需装 Docker：`sudo apt install -y docker.io` | 无（Ubuntu Server 自带 python3） |
| 网络要求 | 要能拉取容器镜像（慢可配镜像加速器） | 只需 pip 装依赖（已走清华镜像，见 §8） |

两点说明：

- docker 执行器下，gitlab-runner 服务以 root 运行，可直接使用本机 Docker，不需要配置用户组。
- shell 执行器下建议用 venv 隔离 CI 的 Python 依赖（见 §8 变体），避免污染系统环境。

---

## 8. 提交 `.gitlab-ci.yml`

在 `milestone/m0`（第一个里程碑分支）就建好这个文件，之后整学期不用改——它调用的是根目录的 `demo.sh`，而 `demo.sh` 随里程碑滚动扩充：

```yaml
# .gitlab-ci.yml —— 每次 push 自动执行 demo.sh 一键自检
stages:
  - validate

variables:
  PIP_DISABLE_PIP_VERSION_CHECK: "1"
  PYTHONUNBUFFERED: "1"
  PIP_INDEX_URL: "https://pypi.tuna.tsinghua.edu.cn/simple"

demo:
  stage: validate
  image: python:3.11-slim        # shell 执行器会忽略本行
  script:
    - python3 -V
    - pip install -r requirements.txt -q
    - bash demo.sh
  rules:
    - if: $CI_COMMIT_BRANCH
```

`shell` 执行器的变体（去掉 `image:`，用 venv 隔离）：

```yaml
demo:
  stage: validate
  script:
    - python3 -m venv .ci-venv
    - .ci-venv/bin/pip install -r requirements.txt -q
    - source .ci-venv/bin/activate && bash demo.sh
  rules:
    - if: $CI_COMMIT_BRANCH
```

> 用 venv 变体时，记得把 `.ci-venv/` 加进 `.gitignore`。

YAML 的两个常见坑：

- `script:` 里某行如果含有「冒号+空格」（`: `），整行要用引号包起来，否则 YAML 解析失败，pipeline 直接红；
- push 之前，可以在仓库的 `Build → Pipeline editor` 里先 Lint 校验一遍语法。

---

## 9. 验收：让构建日志出现

1. 随便 push 一个 commit（或 `git commit --allow-empty -m "ci: 触发首次 pipeline"` 再 push）。
2. 仓库左侧 `Build → Pipelines` 应出现一条新记录；点进去能看到完整 job 日志：装依赖、`demo.sh` 逐里程碑自检、最终退出码 0。
3. 打开你保持 `Open` 的 MR——MR 页面现在会显示 pipeline 状态，助教一眼就能看到「这次提交是能跑通的」。
4. 顺手把最近一次绿色 pipeline 的链接回填到 `README.md` 的里程碑进度表里。

---

## 10. 常见坑

| 坑 | 现象 | 处理 |
| :- | :- | :- |
| runner 不接活 | pipeline 一直 `pending` | 创建 runner 时没勾 `Run untagged jobs`；到 `Settings → CI/CD → Runners` 里编辑勾上 |
| 令牌丢了 | 没有地方能找回 | 令牌只显示一次；删掉旧 runner，按 §5 重建一个即可 |
| pip 超时 | job 日志里装依赖失败 | 确认 `.gitlab-ci.yml` 里有 `PIP_INDEX_URL` 清华镜像变量 |
| 拉不动容器镜像 | docker 执行器卡在 pulling | 配置镜像加速器；或 `sudo gitlab-runner unregister --name my-ubuntu2204` 后改用 shell 执行器重注册 |
| 端口被占 | 第二次跑 `demo.sh` 失败 | `demo.sh` 里起的服务要用 `trap` 收尾杀掉，各里程碑用不同端口 |
| 想「顺便」在 CI 里扫描外部目标 | —— | 绝对禁止：实验目标只允许 `127.0.0.1`，CI 里同样适用（这是课程红线） |

---

## 11. 安全与诚信边界

- runner 只注册在**你自己的仓库**上；令牌和 `/etc/gitlab-runner/config.toml` 不提交进任何仓库。
- 这台 runner 机器是你自己的环境：不要在上面跑来路不明的代码，也不要把 runner 共享给别人的仓库用。
- 把 CI 日志当作你的学术诚信材料来经营：它如实记录了谁在什么时间、让什么代码跑通了。
