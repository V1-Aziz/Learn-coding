---
name: day-31-flashy-flashcard-app
description: "Flashy French→English flashcard app — Tkinter Canvas item IDs + itemconfig, timed card flip with window.after/after_cancel, pandas CSV load/save, try/except progress persistence; completed"
metadata: 
  node_type: memory
  type: project
  originSessionId: f0ea8d4e-6dd8-4e42-92b5-6414fe4cda7d
---

Day 31 "Flashy" — a French→English vocabulary flashcard app (Tkinter + pandas). `main.py` in the Day 31 folder. Completed all 4 steps.

## UI (Step 1)
- 2×2 grid: Canvas on `row=0, columnspan=2`; ❌ button `row=1,col=0`, ✅ button `row=1,col=1`.
- Canvas is `800×526` (matches `card_front.png`); image centered with `create_image(400, 263, ...)` (create_image anchors at CENTER by default).
- Canvas holds 1 image + 2 text items (title + word). `highlightthickness=0`, `bg=BACKGROUND_COLOR` so rounded corners blend.

## Canvas item IDs + itemconfig (key concept)
- Capture the return of `create_image`/`create_text` into variables (`front_image`, `card_title`, `card_word`) so they can be changed later.
- `canvas.itemconfig(item_id, image=..., text=..., fill=...)` mutates an EXISTING item in place. It returns an empty string, NOT an id — always reference the saved id. One image handle, pointed at `front_img` or `back_img`.

## pandas load/save (Steps 2 & 4)
- Load: `to_learn = data.to_dict(orient="records")` → list of `{French, English}` dicts. `random.choice(to_learn)` picks a card.
- Save on ✅ (`i_know()`): `to_learn.remove(current_card)` THEN `pandas.DataFrame(to_learn).to_csv("data/words_to_learn.csv", index=False)` THEN `next_card()`. Order matters — remove before saving/advancing.
- Startup load uses `try/except FileNotFoundError`: try `words_to_learn.csv` (saved progress), fall back to `french_words.csv` (first run). `to_dict` after the block (data set in both branches).
- Mental model: the list is the source of truth; the CSV is a snapshot re-dumped (overwritten) after every change.

## Timed flip (Step 3)
- `flip_timer = window.after(3000, flip_card)` auto-flips card to English (back image + white fill) after 3s.
- `next_card()` starts with `window.after_cancel(flip_timer)` to kill the old countdown before restarting — otherwise stacked timers fire early on new cards.
- `global current_card, flip_timer` needed inside functions that REASSIGN them.

## Gotchas that came up
- Tkinter doesn't hot-reload — must fully close the window and re-run to see edits.
- `global` only works INSIDE a function; at module level it's a no-op.
- `pandas.DataFrame(current_card)` (a single dict) → `ValueError: If using all scalar values, you must pass an index`. Needs a LIST of dicts (`to_learn`).
- `to_csv` without `index=False` writes an index column that becomes `Unnamed: 0` on reload and compounds each cycle.
- `random.choice([])` errors if every word is learned (edge case, unhandled like the course).
