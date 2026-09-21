# AeroSpace Agent Notify

Native macOS notifications for AI-agent completions in an unfocused AeroSpace workspace.

<img width="385" height="132" alt="image" src="https://github.com/user-attachments/assets/c2be50ee-822b-45bf-8a16-701cb72852e8" />


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
