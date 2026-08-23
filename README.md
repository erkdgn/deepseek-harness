# DeepSeek Harness

English | [中文](README.zh.md)

Also available in [Türkçe](README.tr.md).

DeepSeek Harness (`dsh`) is an open-source, general-purpose coding agent: it reads and edits files in a project, runs shell commands, delegates sub-tasks, and keeps a plan, the way Claude Code or a similar agent does. You run it either as a local Web UI or as a one-shot headless command, and you point it at a model provider of your choice by supplying that provider's API key — DeepSeek Harness never ships or requires a key of its own.

It uses an architecture where **everything is a plugin**, and is powered by [Cordis](https://github.com/cordiverse/cordis), whose design is described in [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper). This particular repository, `erkdgn/deepseek-harness`, is a fork of the upstream project that additionally runs `dsh` itself as automated pull request review and issue triage — see the "What this fork adds" section below.

## Developer preview

DeepSeek Harness is currently in _developer preview_ and is iterating rapidly. **THERE WILL BE COMPATIBILITY-BREAKING CHANGES.**

## Run

### 1. Install Node.js

Node.js 22.19+ or 24+ is required (see `engines` in [package.json](package.json)).

### 2. Start the Web UI

```sh
npx @deepseek-ai/dsh web
```

The command downloads and starts `dsh`, serving the Web UI at `http://127.0.0.1:3080` by default and opening it in the default browser for a local launch. An SSH launch only prints the host URL because the SSH client or editor owns the local forwarded address. Pass `--no-open` to run the server without opening a browser. See the [Web UI guide](docs/user/guide/index.md).

### 3. Add a model provider

Open **Settings → Models** in the Web UI and enter an API key for a supported provider — DeepSeek's own API, or another provider such as Anthropic, OpenAI, or a self-hosted/OpenAI-compatible gateway. The [model configuration guide](docs/user/guide/providers.md) covers every supported shape, including custom providers.

### 4. Choose a workspace and run a task

Click **Choose workspace**, add the project directory `dsh` was started from, then start a session and send it a task, for example "Summarize this repository and identify its main packages." The agent reads and edits workspace files, runs commands, and asks for approval under the active permission policy before an operation that needs it. The full walkthrough is in the [Web UI guide](docs/user/guide/index.md).

## Run from source

To run from a repository checkout instead of the published `npm` package — for example, to use this fork's exact code, or to make changes yourself:

```sh
git clone https://github.com/erkdgn/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

`pnpm run build` prepares the repository artifacts, and `pnpm dsh web` uses those built artifacts without rebuilding. See the [development guide](docs/development.md) for the full contributor setup and daily workflow.

## What this fork adds

Beyond running `dsh` as your own coding agent, this fork also runs `dsh` itself as an automated second opinion — both on demand while you work, and unattended in CI against this repository's own pull requests and issues.

### Automated PR review and issue triage

- **On `pull_request` events** (opened, synchronized, reopened), a job installs `dsh`, points it at a configured model, and posts a Markdown review comment covering correctness, security, concurrency, and missing error handling — advisory only, never blocking.
- **On newly opened issues**, a job asks `dsh` to propose labels, then applies only the ones that appear both in an explicit allowlist and in this repository's real `gh label list` output — so neither a model mistake nor a prompt-injection attempt buried in an issue body can apply an arbitrary label.
- Every failure path (missing key, timeout, provider error, empty response) posts a plain comment saying what happened and exits successfully — a broken automation run never blocks a pull request or leaves an issue silently untriaged.

### Set it up

Under **Settings → Secrets and variables → Actions** on this repository:

| Type | Name | Value |
|---|---|---|
| Secret | `DSH_PROVIDER_API_KEY` | API key for whichever model provider you configure below — the name is provider-agnostic, so switching providers is never a secret rename. |
| Variable (optional) | `DSH_PROVIDER_ID` | `llm-pi-ai` route name. Defaults to `ollama`. |
| Variable (optional) | `DSH_PROVIDER_BASE_URL` | Defaults to `https://ollama.com/v1`. |
| Variable (optional) | `DSH_PROVIDER_API` | Wire protocol: `openai-completions` (default), `openai-responses`, or `anthropic-messages`. |
| Variable (optional) | `DSH_MODEL_ID` | Defaults to `deepseek-v4-pro:0813`. |
| Variable (optional) | `DSH_ALLOWED_LABELS` | Comma-separated labels triage may apply. Keep this in sync with this repository's real labels. |
| Variable (optional) | `MAX_DIFF_LINES`, `MAX_PROMPT_BYTES`, `DSH_REVIEW_TIMEOUT_SECONDS`, `DSH_TRIAGE_TIMEOUT_SECONDS` | Diff-size budget, prompt-byte budget (below the shell's single-argument limit), and per-job timeouts. |

Once the secret is set, open (or push to) a pull request or open an issue on this repository to see it run — check the Actions tab for the job's output.

### Consult dsh yourself

The same profile is available for manual, on-demand consultation, for example before a security- or concurrency-sensitive change:

```sh
dsh --profile headless "<question, with the code pasted in full>"
```

Run this from the repository root. `dsh` keeps no history between calls, so paste the code directly into the prompt rather than referring to "the function above."

### Where this is documented, and its known limits

The [`dsh-integration` skill](.agents/skills/dsh-integration/SKILL.md) is the full reference: the profile's permission/sandbox/approval configuration, the exact prompt rules, the workflow and script files, and troubleshooting.

This automation has been verified three ways: every branch of the review and triage scripts (oversized diff, fetch failure, timeout, provider error, empty response, label filtering) against stubbed `gh`/`dsh`; the actual published `@deepseek-ai/dsh` package installing and composing this exact profile successfully against a real (if unreachable, from a restricted sandbox) provider request; and a real trigger inside this repository's own GitHub Actions, before the secret was ever set — which surfaced a real gap (a missing secret failed the job outright instead of posting an advisory comment) that has since been fixed. **A run against a live, reachable provider has still not been observed**; set the secret described above to see one, and check the Actions log if that first run behaves unexpectedly.

## Community and support

`erkdgn/deepseek-harness` is a fork of the upstream [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) project, used here to run the DSH review and triage automation described above. File feedback or bug reports for this fork through its own [GitHub Issues](https://github.com/erkdgn/deepseek-harness/issues); for the upstream product's own community and support channels, see [its README](https://github.com/deepseek-ai/deepseek-harness#readme).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

Start with the [development guide](docs/development.md) and [architecture documentation](docs/architecture.md).

For agents, follow [AGENTS.md](AGENTS.md).

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
