# AeroSpace Agent Notify

Native macOS notifications for AI-agent completions in an unfocused AeroSpace workspace.

<img width="385" height="132" alt="image" src="https://github.com/user-attachments/assets/b9ae7db2-6b0d-483e-88f5-dcacb0f5424e" />

## Supported environment

v1 supports **macOS**, AeroSpace, iTerm2, and Claude Code. Codex and other terminals are planned, not yet supported.

## Install

From a trusted checkout:

```sh
./install.sh
aerospace-agent-notify doctor
aerospace-agent-notify test-notification
```

The installer backs up and updates only this project's Claude Code hook entries. Waiting workspace names are stored at `~/.cache/aerospace-agent-notify/waiting-workspaces`; no prompts or terminal content are retained.

## Remove

```sh
./uninstall.sh
./uninstall.sh --purge-data
```

## License

MIT. Requires [AeroSpace](https://github.com/nikitabobko/AeroSpace).
