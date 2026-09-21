"""Claude Code settings transformations owned by aerospace-agent-notify."""

import copy
import json
import sys

MARKER = "aerospace-agent-notify"


def _owned(command):
    return {"type": "command", "command": f"{command} # {MARKER}"}


def _strip_owned(groups):
    kept = []
    for group in groups:
        original_hooks = group.get("hooks", [])
        hooks = [hook for hook in original_hooks if MARKER not in hook.get("command", "")]
        if hooks or not any(MARKER in hook.get("command", "") for hook in original_hooks):
            clone = copy.deepcopy(group)
            clone["hooks"] = hooks
            kept.append(clone)
    return kept


def install_hooks(settings, command):
    settings = copy.deepcopy(settings)
    hooks = settings.setdefault("hooks", {})
    for event in ("Stop", "Notification"):
        groups = _strip_owned(hooks.get(event, []))
        groups.append({"hooks": [_owned(command)]})
        hooks[event] = groups
    return settings


def remove_hooks(settings):
    settings = copy.deepcopy(settings)
    hooks = settings.get("hooks", {})
    for event in ("Stop", "Notification"):
        if event in hooks:
            hooks[event] = _strip_owned(hooks[event])
    return settings


def main(argv):
    if len(argv) not in (3, 4) or argv[0] not in ("install", "remove"):
        return 64
    try:
        with open(argv[1]) as source:
            settings = json.load(source)
    except (OSError, json.JSONDecodeError):
        return 2
    result = install_hooks(settings, argv[3]) if argv[0] == "install" and len(argv) == 4 else remove_hooks(settings)
    with open(argv[2], "w") as output:
        json.dump(result, output, indent=2)
        output.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
