---
name: day-29-password-manager-gui-app
description: "Password Manager with Tkinter: grid layout, password generator (list comprehensions), save to data.txt with validation and confirmation dialog, pyperclip"
metadata: 
  node_type: memory
  type: project
  originSessionId: bc3922ef-311f-4eda-bed6-13ad0b212efb
---

Built a full Password Manager GUI app with Tkinter.

## UI Layout
- 3-column grid layout using `.grid()`
- Canvas with `logo.png` (row 0, col 1)
- Website entry (row 1, colspan 2)
- Email/Username entry (row 2, colspan 2)
- Password entry (row 3, col 1) + Generate Password button (row 3, col 2)
- Add button (row 4, colspan 2)
- `website_input.focus()` to auto-focus first field on launch

## Password Generator (`password_generator()`)
- Three separate list comprehensions for letters, numbers, symbols
- Combined with `+` into `password_list`
- `random.shuffle(password_list)` to randomize order
- `"".join()` style loop to build string
- `password_input.delete(0, END)` before `password_input.insert(0, password)` to clear on regenerate
- `pyperclip` imported (auto-copy to clipboard)

## Save Function (`save()`)
- Validates all fields with `if not field` check first — shows `showerror` if any empty
- Then shows `askokcancel` confirmation dialog
- Only writes to `data.txt` (append mode `"a"`) if `is_ok` is True
- Clears all three Entry fields after saving
- Format: `website|email|password\n`

## Key lessons
- Tkinter widgets must be placed with `.grid()`/`.pack()`/`.place()` — unlike HTML they don't auto-render
- `.insert(index, string)` inserts text into Entry; `.delete(0, END)` clears it
- `askokcancel` returns True/False — must check result before acting
- Order matters: validate empty fields BEFORE showing confirmation dialog
- File mode `"a"` appends; `"w"` truncates
