---
name: day-28-pomodoro-timer
description: "Pomodoro GUI timer app with Tkinter — countdown, work/break cycles, checkmarks, reset"
metadata: 
  node_type: memory
  type: project
  originSessionId: 001c4fdc-5ca3-458c-b816-659161e96e32
---

**Topic:** Building a Pomodoro Timer GUI app with Tkinter.

**Status:** Completed (2026-06-06)

**Key concepts covered:**
- `window.after(ms, func, args)` — recursive countdown mechanism (calls itself every 1000ms)
- `window.after_cancel(timer)` — cancels a scheduled `after()` call (used in reset)
- `canvas.itemconfig()` — updates canvas text dynamically
- `math.floor()` — converts seconds to minutes for display
- Global `rep` counter to track work/break cycles (every 2 reps = break, every 8 = long break)
- Check marks (`✔`) added to label based on completed work sessions

**Project structure:**
- `reset_timer()` — cancels timer, resets canvas text, label, checkmarks, and rep counter
- `start_timer()` — increments rep, decides work/break type, calls `count_down()`
- `count_down(count)` — recursive countdown, triggers `start_timer()` when done

**macOS notes:**
- Tkinter `Button` bg color doesn't work on macOS (post-2021 update broke it)
- `tkmacosx` library is broken on Python 3.12
- Window not auto-focusing is a known macOS/Python issue — use Cmd+Tab as workaround
