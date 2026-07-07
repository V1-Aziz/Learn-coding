# Claude Code Memory Backup — Python 100 Days Course

This folder is a **snapshot** of Claude Code's project memory for the *100 Days of Code* Python course. It lets the teaching context (course progress, how I like to be taught, per-day notes) follow me across my machines (macOS MacBook + Windows PC).

## Why it's here and not "just working"

Claude Code stores memory **outside** this repo, in a per-project folder:

- macOS/Linux: `~/.claude/projects/<encoded-project-path>/memory/`
- Windows: `%USERPROFILE%\.claude\projects\<encoded-project-path>\memory\`

The `<encoded-project-path>` is derived from the project's **absolute path**, which differs per machine/OS. So this repo folder is a portable backup — you copy it **into** the live memory folder on each machine.

## Install on another machine (e.g. Windows)

**Easiest:** open Claude Code in the `python/Learning` folder and say:

> "Install the memories from `python/Learning/claude-memory` into your memory folder."

Claude Code knows its own memory path and will copy them into the right place.

**Manual:** copy everything in this folder (except this README) into:

```
%USERPROFILE%\.claude\projects\<encoded-project-path>\memory\
```

To find `<encoded-project-path>`, open Claude Code in the project once — it creates the folder — or ask it "what's your memory directory for this project?"

## Keeping it in sync

This is a **manual snapshot**, not a live link. After memories change on one machine:

1. Copy the live `memory/` folder contents back into this `claude-memory/` folder.
2. `git add`, `commit`, `push`.
3. On the other machine: `git pull`, then re-install as above.

Golden rule from the main workflow: **pull before you start, push when you finish.**
