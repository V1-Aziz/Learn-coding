---
name: feedback-read-code-first
description: Always read the code file from disk before asking the user to paste code
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 084371ca-01a7-44a2-809a-9b78a627e0ad
---

Always read the code file from the working directory directly. Never ask the user to paste their code.

**Why:** User expects the assistant to look at the file directly rather than asking them to paste it.

**How to apply:** When the user asks about their code or an error, immediately read main.py (or the relevant file) from the current day's directory before responding.
