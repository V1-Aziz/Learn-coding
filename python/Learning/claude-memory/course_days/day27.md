---
name: day-27-tkinter-and-args-kwargs
description: "Tkinter GUI programming, *args, **kwargs — completed"
metadata: 
  node_type: memory
  type: project
  originSessionId: 13001c51-fadc-4754-a48d-3b811e7808a4
---

Day 27 covers Tkinter (Python's built-in GUI library), *args (variable positional arguments), and **kwargs (variable keyword arguments).

**Topics:**

`*args` (playground.py — commented out):
- `def add(*args)` — loops over args and sums them
- Called with `add(1,2,3,4,5,6,7,8,9,10)`

`**kwargs` (playground.py — active):
- `def calculate(**kwargs)` — prints the kwargs dict
- `class Car` uses `**kw` in `__init__`, accesses values with `kw.get("key")` — avoids AttributeError if key is missing
- Instantiated with `Car(make="Nissan", model="GTR", seats=2, color="red")`

Tkinter (main.py):
- `Tk()` — creates the window
- `window.title()`, `window.minsize()` — window config
- `window.config(padx=..., pady=...)` — adds padding around the window content
- `Label(text=..., font=(...))` — display text
- `label["text"] = ...` and `label.config(text=...)` — update label
- `Button(text=..., command=fn)` — clickable button
- `Entry(width=...)` + `.get()` — text input field; `.get()` retrieves typed text
- `.grid(column=X, row=Y)` — positions widgets in a dynamic grid (no fixed size; grows as widgets are placed)
- Grid rows/columns are 0-indexed; currently spans columns 0–3, rows 0–3
- Button `command` only accepts one callable; wrap multiple calls in a wrapper function

**Status:** Completed

**Why:** Part of the 100 Days of Code bootcamp sequence following Day 26 (comprehensions + pandas).

**Project — Mile to Km Converter** (`mile_kilometter_convertor.py`):
- `Entry` + `.get()` inside the function to read user input at click time (not at startup)
- `int(mile_input.get())` — convert string input to number inside the function
- `converted_label["text"] = result` — update result label on button click
- `command=convert_mile_kilometer` — pass function reference, no args, no call
- Conversion factor: `mile * 1.609`
- Common mistake: calling `command=fn(arg)` executes immediately — must be `command=fn`

**How to apply:** `playground.py` has *args/**kwargs practice; `main.py` has Tkinter practice; `mile_kilometter_convertor.py` is the project.
