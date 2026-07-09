---
name: day24-file-manipulation
description: "Day 24 - File manipulation: persist Snake game high score to data.txt (read on start, write on reset)"
metadata: 
  node_type: memory
  type: project
  originSessionId: e3143741-ce0b-4c3a-8aa4-661e80a10b98
---

# Day 24 — Files, Directories & Paths (Snake high-score persistence)

Status: ✅ Core working 2026-06-02

## What was built
Added persistent high-score storage to the Day 21 Snake game's `scoreboard.py`:
- On `__init__`: `with open("data.txt") as score: self.high_score = int(score.read())` — reads the saved high score at startup.
- On `reset()`: if `self.score > self.high_score`, calls `save_score()` then updates `self.high_score`.
- `save_score()`: `with open("data.txt", "w") as score: score.write(str(self.score))` — writes new high score.

## Concepts practiced
- File modes: `"w"` **truncates the file to empty on open** and can't be `.read()`; default/`"r"` reads without erasing.
- `with open(...)` context manager (auto-closes); `with` blocks belong **inside methods**, not wrapped around the class definition.
- Type conversion: `score.read()` returns a **string**; need `int(...)` before numeric comparison/display (else `int > str` TypeError).

## Bugs the user debugged
1. Opened `data.txt` with `mode="w"` to read it — wiped the file AND `.read()` errors on write-mode files. (User first thought file was empty only because they "forgot to add 0" — actual cause was `"w"` truncating.)
2. Whole `class Scoreboard` was nested inside a `with open(...)` block.
3. Compared `int` score to `str` high_score — fixed with `int(score.read())`.
4. Leftover dead `with open("data.txt")` in `update_score()` that opened the file every frame but never used it — removed. (`update_score` should only `clear()` + `write()` to screen.)

## Known fragility (not fixed)
- If `data.txt` is ever empty, `int(score.read())` raises `ValueError` on startup — game won't launch. Could guard with a try/except or default value later.
- Minor redundancy: `reset()` checks `score > high_score` and `save_score()` re-checks the same condition.

## Mail Merge project (✅ done 2026-06-02)
Located in `Day 24/Mail merging/`. Reads `Input/Names/invited_names.txt` (`readlines()`) and `Input/Letters/starting_letter.txt` (`read()`), then per name replaces `[name]` placeholder and writes a personalized letter to `Output/ReadyToSend/invite_for_{name}.txt`.

Key bug debugged: `readlines()` keeps the trailing `\n` on each name. Since the template is `Dear [name],`, the unstripped name made the comma fall to its own line, AND the output filenames had a literal newline (`invite_for_Aang\n.txt`). Fix: strip once at top of loop into a variable, reuse it for both the letter body and the filename. Lesson reinforced: prefer plain `.strip()` over `.strip("\n")`, and strip once rather than per-use.

See [[day21-class-inheritance-snake-game-part-2]] for the base Snake game.
