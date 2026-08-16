# DeepSeek Harness

[English](README.md) | 中文 | [Türkçe](README.tr.md)

DeepSeek Harness（`dsh`）是一个开源的通用编码 agent（智能体）：它能读写项目中的文件、运行 shell 命令、委派子任务、并维护一份计划，就像 Claude Code 或类似的 agent 那样工作。你可以把它作为本地 Web UI 运行，也可以作为一次性的 headless 命令运行；你需要提供所选模型 provider 自己的 API key 来指向它——DeepSeek Harness 本身不附带、也不需要自己的 key。

它采用**一切皆插件**的架构，并由 [Cordis](https://github.com/cordiverse/cordis) 驱动，其设计参见论文 [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper)。本仓库 `erkdgn/deepseek-harness` 是上游项目的一个 fork，额外运行 `dsh` 自身来做自动化的拉取请求审查与 issue 分类——见下文的“本 fork 新增内容”一节。

## 开发者预览

DeepSeek Harness 目前处于 _开发者预览_ 阶段，正在快速迭代。**未来将出现破坏兼容性的变更。**

## 运行

### 1. 安装 Node.js

需要 Node.js 22.19+ 或 24+（见 [package.json](package.json) 中的 `engines`）。

### 2. 启动 Web UI

```sh
npx @deepseek-ai/dsh web
```

该命令会下载并启动 `dsh`，默认在 `http://127.0.0.1:3080` 提供 Web UI。在浏览器中打开该地址。

### 3. 添加模型 provider

在 Web UI 中打开 **Settings → Models**，为某个受支持的 provider 输入 API key——可以是 DeepSeek 自己的 API，也可以是 Anthropic、OpenAI 等其他 provider，或者一个自建的／OpenAI 兼容的网关。[模型配置指南](docs/user/guide/providers.md) 覆盖了每一种受支持的形态，包括自定义 provider。

### 4. 选择工作区并运行任务

点击 **Choose workspace**，添加 `dsh` 启动时所在的项目目录，然后开始一个会话并发送一个任务，例如「总结这个仓库并识别它的主要包」。agent 会读写工作区中的文件、运行命令，并在需要时按照当前生效的权限策略请求批准。完整流程见 [Web UI 指南](docs/user/guide/index.md)。

## 从源码运行

如果要从仓库源码运行，而不是使用已发布的 `npm` 包——例如需要用到本 fork 的确切代码，或者你自己要做修改：

```sh
git clone https://github.com/erkdgn/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

完整的贡献者搭建与日常工作流见[开发指南](docs/development.md)。

## 本 fork 新增内容

除了把 `dsh` 当作你自己的编码 agent 来运行之外，本 fork 还将 `dsh` 自身作为一个自动化的第二意见来源来运行——既支持你在工作时按需咨询，也会无人值守地在 CI 中针对本仓库自己的 pull request 和 issue 运行。

### 自动化 PR 审查与 issue 分类

- **在 `pull_request` 事件上**（opened、synchronize、reopened），一个 job 会安装 `dsh`，将其指向配置好的模型，并发布一条覆盖正确性、安全性、并发问题与缺失错误处理的 Markdown 审查评论——仅作参考，绝不阻塞。
- **在新开的 issue 上**，一个 job 会请求 `dsh` 提出标签建议，然后只应用同时出现在显式 allowlist 中、且真实存在于本仓库 `gh label list` 输出中的那些标签——这样无论是模型出错，还是 issue 正文里藏着的一次 prompt-injection 尝试，都无法应用一个任意标签。
- 每条失败路径（缺少 key、超时、provider 出错、空响应）都会发布一条说明发生了什么的普通评论并以成功状态退出——一次损坏的自动化运行永远不会阻塞 pull request，也不会让某个 issue 悄无声息地未被分类。

### 如何搭建

在本仓库的 **Settings → Secrets and variables → Actions** 下：

| 类型 | 名称 | 值 |
|---|---|---|
| Secret | `DSH_PROVIDER_API_KEY` | 你在下面配置的那个模型 provider 的 API key——这个名字与具体 provider 无关，因此切换 provider 从不需要重命名 secret。 |
| Variable（可选） | `DSH_PROVIDER_ID` | `llm-pi-ai` 的 route 名称，默认为 `ollama`。 |
| Variable（可选） | `DSH_PROVIDER_BASE_URL` | 默认为 `https://ollama.com/v1`。 |
| Variable（可选） | `DSH_PROVIDER_API` | 传输协议：`openai-completions`（默认）、`openai-responses` 或 `anthropic-messages`。 |
| Variable（可选） | `DSH_MODEL_ID` | 默认为 `deepseek-v4-pro:0813`。 |
| Variable（可选） | `DSH_ALLOWED_LABELS` | 分类可应用的标签，逗号分隔。请与本仓库真实的标签保持同步。 |
| Variable（可选） | `MAX_DIFF_LINES`、`MAX_PROMPT_BYTES`、`DSH_REVIEW_TIMEOUT_SECONDS`、`DSH_TRIAGE_TIMEOUT_SECONDS` | diff 大小预算、prompt 字节预算（低于 shell 单参数长度上限）与各 job 的超时时间。 |

设置好 secret 后，在本仓库打开（或推送到）一个 pull request，或者新开一个 issue，即可看到它运行——在 Actions 标签页查看该 job 的输出。

### 自己咨询 dsh

同一个 profile 也可用于手动、按需的咨询，例如在一次涉及安全或并发的改动之前：

```sh
dsh --profile headless "<question, with the code pasted in full>"
```

从仓库根目录运行此命令。`dsh` 在调用之间不保留任何历史，所以请把代码直接粘贴进 prompt，而不要引用「上面那个函数」。

### 完整文档在哪，以及已知限制

[`dsh-integration` 技能](.agents/skills/dsh-integration/SKILL.md) 是完整的参考文档：该 profile 的 permission/sandbox/approval 配置、确切的 prompt 规则、workflow 与脚本文件，以及排障方法。

这套自动化经过两种方式的验证：针对 stub 化的 `gh`/`dsh`，覆盖了审查与分类脚本的每一条分支（超大 diff、拉取失败、超时、provider 出错、空响应、标签过滤）；以及实际已发布的 `@deepseek-ai/dsh` 包成功安装并组合出这个确切的 profile，并对一个真实的（尽管在受限沙箱中无法连通）provider 发起了真实请求。**尚未在真正的 GitHub Actions 中针对一个可连通的 provider 观察到完整的一次运行**——第一次真实触发可能需要对 bootstrap 做微调；如果某个 job 的第一次运行行为异常，请检查 Actions 日志。

## 社区与支持

`erkdgn/deepseek-harness` 是上游 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 项目的一个 fork，用于运行上文描述的 DSH 审查与分类自动化。针对本 fork 的反馈或 bug 报告，请通过本仓库自己的 [GitHub Issues](https://github.com/erkdgn/deepseek-harness/issues) 提交；上游产品自身的社区与支持渠道见[其 README](https://github.com/deepseek-ai/deepseek-harness#readme)。

## 参与贡献

参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 开发

请先阅读[开发指南](docs/development.md)与[架构文档](docs/architecture.md)。

面向 agent：请遵循 [AGENTS.md](AGENTS.md)。

## 许可证

[MIT](LICENSE)

第三方依赖及其许可证见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
