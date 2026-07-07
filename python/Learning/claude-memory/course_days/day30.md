---
name: day-30-password-manager-search-feature-json
description: Extended Day 29 password manager with JSON storage and find_password() search function; try/except for file errors and missing entries
metadata: 
  node_type: memory
  type: project
  originSessionId: bc3922ef-311f-4eda-bed6-13ad0b212efb
---

Extended the Day 29 Password Manager to use JSON and added a search feature. Same file (main.py in Day 29 folder).

## Changes from Day 29
- Switched storage from `data.txt` (plain text append) to `data.json`
- JSON format: `{ "website": { "email": "...", "password": "..." } }`

## Save function updated for JSON
- Reads existing `data.json`, updates with new entry, writes back with `json.dump(data, data_file, indent=1)`
- Uses `try/except (FileNotFoundError, json.JSONDecodeError)` — if file missing or empty, starts fresh with `new_data`
- Variable naming pitfall: file handle and loaded dict must have different names to avoid shadowing

## find_password() function
- Triggered by "Search" button (column 2, row 1 in grid)
- `try/except FileNotFoundError` wraps the entire `with open(...)` block
- Inside: checks `if website in data` first, THEN extracts `data[website]["email"]` and `data[website]["password"]`
- Shows `showinfo` with found credentials, or `"No details for the website exists"` if not found, or `"No Data File Found"` if file missing

## Key lessons
- `json.load()` on empty file raises `JSONDecodeError` — always handle it
- Check `if key in dict` BEFORE accessing `dict[key]` to avoid KeyError
- `dict[key1][key2]` to access nested dicts
- `open()` in `"w"` mode truncates the file immediately — always read first, then write back the merged result
- `messagebox.showinfo(title, message)` needs both arguments
