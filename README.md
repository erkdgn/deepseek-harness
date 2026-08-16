# DeepSeek Harness

English | [中文](README.zh.md) | [Türkçe](README.tr.md)

DeepSeek Harness (`dsh`) is an open-source agent harness developed by [DeepSeek AI](https://deepseek.com).

It uses an architecture where **everything is a plugin**, and is powered by [Cordis](https://github.com/cordiverse/cordis), whose design is described in [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper).

## Developer preview

DeepSeek Harness is currently in _developer preview_ and is iterating rapidly. **THERE WILL BE COMPATIBILITY-BREAKING CHANGES.**

## Run

### Run from `npm`

Install `Node.js`, then run:

```sh
npx @deepseek-ai/dsh web
```

The command starts the Web UI, served at `http://127.0.0.1:3080` by default. See [Web UI guide](docs/user/guide/index.md).

### Run from source

To run from a repository checkout:

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

## Community and support

- Feel free to submit feedback or bug reports through [GitHub Discussions](https://github.com/deepseek-ai/deepseek-harness/discussions).
- Add the [`dsh-plugin`](https://github.com/topics/dsh-plugin) topic to your plugin repository for discoverability.
- Join <a href="https://discord.gg/Ycq5dCaS4">DeepSeek Harness Discord community</a>.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

Start with the [development guide](docs/development.md) and [architecture documentation](docs/architecture.md).

For agents, follow [AGENTS.md](AGENTS.md).

## DSH-powered review automation

This fork also runs `dsh` itself as an automated second opinion, on demand and in CI. For manual consultation, run `dsh --profile headless "<question>"` from the repository root with the code pasted directly into the prompt — `dsh` keeps no history between calls. On `pull_request` events it posts an automated review comment, and on newly opened issues it proposes and applies labels filtered against this repository's live label list; every failure path there is non-blocking. Enable both by setting the `OLLAMA_API_KEY` secret (and optionally the `DSH_MODEL_ID`, `DSH_ALLOWED_LABELS` repository variables) under Settings → Secrets and variables → Actions. Full setup, prompt rules, and troubleshooting live in the [`dsh-integration` skill](.agents/skills/dsh-integration/SKILL.md).

## License

[MIT](LICENSE)

Third-party dependencies and their licenses are disclosed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
