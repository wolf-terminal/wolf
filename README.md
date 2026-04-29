# Wolf Terminal

A fork of [Warp](https://github.com/warpdotdev/warp) — personalized for Ellen Wolf's workflow, with the Mysteria Gradient theme, SuperSansMono font, and Wolf Workflow Kit pre-configured.

## What's different from Warp OSS

- **Mysteria Gradient theme** (`themes/wolf.yaml`) — Superhuman brand palette, dark
- **SuperSansMono font** — Superhuman brand monospace, bundled in `fonts/`
- **Claude Code as default agent** — configured in `defaults/settings.toml`
- **WFK install script** — `script/install-wfk.sh` sets up Wolf Workflow Kit skills, settings, and MCP stubs

v2 (when Thomas commits): app name, dock icon, and in-app Warp → Wolf rebranding (requires Rust changes).

## Requirements

- macOS (Apple Silicon or Intel)
- [Xcode](https://apps.apple.com/us/app/xcode/id497799835) — required to build Metal shaders
- Rust (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)

## Build

```bash
git clone https://github.com/wolf-terminal/wolf.git
cd wolf
./script/bootstrap    # installs system deps (requires Xcode.app)
cargo build
```

## First launch — Warp account required

Wolf v1 is built on Warp's open-source codebase, which uses Warp's authentication system. You'll need a free Warp account to sign in on first launch.

1. Create a free account at [warp.dev](https://warp.dev) if you don't have one
2. On first launch, sign in with your Warp credentials
3. You only need to do this once — Wolf stores your session

## First launch — macOS Gatekeeper

Because Wolf is unsigned, macOS will block the first launch:

1. Try to open Wolf — macOS shows "cannot be opened because the developer cannot be verified"
2. Open **System Settings → Privacy & Security**
3. Scroll down and click **"Allow Anyway"**
4. Open Wolf again and click **Open**

You only need to do this once.

## WFK Setup

After building, run the setup script to install Wolf Workflow Kit:

```bash
./script/install-wfk.sh
```

This installs WFK skills, Claude Code settings, and MCP stubs from the public
[wolf-workflow-kit](https://github.com/ellenwolf0-hub/wolf-workflow-kit) repo.
It never overwrites `~/.claude/settings.local.json` or your `LOCAL.md` files.

## License

AGPL v3 — see [LICENSE](LICENSE). Forked from [warpdotdev/warp](https://github.com/warpdotdev/warp).

---

## About Warp (upstream)

## Installation

You can [download Warp](https://www.warp.dev/download) and [read our docs](https://docs.warp.dev/) for platform-specific instructions.

## Licensing

Warp's UI framework (the `warpui_core` and `warpui` crates) are licensed under the [MIT license](LICENSE-MIT).

The rest of the code in this repository is licensed under the [AGPL v3](LICENSE-AGPL).

## Open Source & Contributing

Warp's client codebase is open source and lives in this repository. We welcome community contributions and have designed a lightweight workflow to help new contributors get started. For the full contribution flow, read our [CONTRIBUTING.md](CONTRIBUTING.md) guide.

### Issue to PR

Before filing, [search existing issues](https://github.com/warpdotdev/warp/issues?q=is%3Aissue+is%3Aopen+sort%3Areactions-%2B1-desc) for your bug or feature request. If nothing exists, [file an issue](https://github.com/warpdotdev/warp/issues/new/choose) using our templates. Security vulnerabilities should be reported privately as described in [CONTRIBUTING.md](CONTRIBUTING.md#reporting-security-issues).

Once filed, a Warp maintainer reviews the issue and may apply a readiness label: [`ready-to-spec`](https://github.com/warpdotdev/warp/issues?q=is%3Aissue+is%3Aopen+label%3Aready-to-spec) signals the design is open for contributors to spec out, and [`ready-to-implement`](https://github.com/warpdotdev/warp/issues?q=is%3Aissue+is%3Aopen+label%3Aready-to-implement) signals the design is settled and code PRs are welcome. Anyone can pick up a labeled issue — mention **@oss-maintainers** on an issue if you'd like it considered for a readiness label.

### Building the Repo Locally

To build and run Warp from source:

```bash
./script/bootstrap   # platform-specific setup
./script/run         # build and run Warp
./script/presubmit   # fmt, clippy, and tests
```

See [WARP.md](WARP.md) for the full engineering guide, including coding style, testing, and platform-specific notes.

## Joining the Team

Interested in joining the team? See our [open roles](https://www.warp.dev/careers).

## Support and Questions

1. See our [docs](https://docs.warp.dev/) for a comprehensive guide to Warp's features.
2. Join our [Slack Community](https://go.warp.dev/join-preview) to connect with other users and get help from the Warp team.
3. Try our [Preview build](https://www.warp.dev/download-preview) to test the latest experimental features.
4. Mention **@oss-maintainers** on any issue to escalate to the team — for example, if you encounter problems with the automated agents.

## Code of Conduct

We ask everyone to be respectful and empathetic. Warp follows the [Code of Conduct](CODE_OF_CONDUCT.md). To report violations, email warp-coc at warp.dev.

## Open Source Dependencies

We'd like to call out a few of the [open source dependencies](https://docs.warp.dev/help/licenses) that have helped Warp to get off the ground:

* [Tokio](https://github.com/tokio-rs/tokio)
* [NuShell](https://github.com/nushell/nushell)
* [Fig Completion Specs](https://github.com/withfig/autocomplete)
* [Warp Server Framework](https://github.com/seanmonstar/warp)
* [Alacritty](https://github.com/alacritty/alacritty)
* [Hyper HTTP library](https://github.com/hyperium/hyper)
* [FontKit](https://github.com/servo/font-kit)
* [Core-foundation](https://github.com/servo/core-foundation-rs)
* [Smol](https://github.com/smol-rs/smol)
