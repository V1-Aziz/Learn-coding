---
name: learning-github-repo
description: "User's GitHub repo for syncing Udemy course work across a Windows PC and a macOS MacBook"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f0ea8d4e-6dd8-4e42-92b5-6414fe4cda7d
---

The user syncs their Udemy learning across two machines (Windows PC + macOS MacBook) via GitHub.

- **Repo:** https://github.com/V1-Aziz/Learn-coding.git (remote `origin`, branch `main`). Renamed from `Lean-coding` (typo fix) on 2026-07-08; old URL still redirects.
- **Git root (macOS):** `/Users/abdulazizalghamdi/Learning/Udemy` — the WHOLE Udemy folder is the repo, not just the Python course. Python course lives under `python/Learning/`.
- **`.gitignore`** at the root already covers Python (`__pycache__/`, `*.pyc`, `venv/`, `.env`), OS/editor (`.DS_Store`, `.idea/`, `.vscode/`), and Flutter build output. Working fine — no junk tracked.
- The full Flutter SDK is committed under `Flutter & Dart/flutter/` (makes the repo large; some `.idea/*.tmpl` files are Flutter's own templates, tracked before the gitignore existed — harmless).

**Cross-device workflow:** pull before starting, push when finishing. Committing/pushing is outward-facing — only do it when the user explicitly asks. See [[feedback_read_before_save]] pattern for reading files before acting.
