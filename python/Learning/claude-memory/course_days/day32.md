---
name: day-32-smtp-datetime-birthday-wisher
description: "Day 32 — smtplib email sending + datetime; Monday quote sender and the extra-hard Automated Birthday Wisher (pandas (month,day) lookup, random letter, dynamic recipient); completed"
metadata: 
  node_type: memory
  type: project
  originSessionId: day32-session
---

Day 32 — Sending Email (`smtplib`) & Managing Dates (`datetime`). All done, credentials moved to env vars, pushed to repo.

## Files (in `Day 32/`, moved to folder root — NOT the extra-hard subfolder)
- `main.py` — the Automated Birthday Wisher (extra-hard version)
- `challenge1.py` — Monday motivational quote sender
- `birthdays.csv` — name, email, year, month, day
- `letter_templates/letter_1..3.txt` — templates with `[NAME]` placeholder
- `quotes.txt` — quote pool for the Monday sender
- `STEPS.md` — self-authored step guide (user asked for it to stop scrolling chat)

## smtplib email pattern (learned this day)
- `with smtplib.SMTP("smtp.gmail.com") as connection:` → `starttls()` → `login(user, password)` → `sendmail(from_addr, to_addrs, msg)`.
- Gmail rejects the real account password (`535 BadCredentials`). Must enable 2FA and use a 16-char **App Password**. Hotmail/Outlook personal accounts disabled basic SMTP AUTH (Sep 2024) → OAuth2 only, so user used a second Gmail instead.
- `msg` needs `f"Subject:...\n\n body"` — the `Subject:` line + blank line is what makes the subject render.
- First bug: `password=my_email` (passed email as the password) — a copy/paste slip.

## datetime
- `dt.datetime.now()` → `.month`, `.day`, `.weekday()`. `.weekday()` returns a NUMBER (Mon=0 … Sun=6), Thursday=3, Monday=0.
- Key mental-model fix: `.weekday()`/`.month`/`.day` are **read off** the datetime object (outputs), they don't take an argument. User first wrote `dt.datetime.weekday(4)` → `TypeError: descriptor 'weekday' ... doesn't apply to 'int'`.

## Birthday Wisher — key concepts the user debugged solo
- **Tuple as dict key:** `{ (row.month, row.day): row for (index, row) in data.iterrows() }`. A birthday is identified by month AND day together → tuple. User initially made key=month only (collisions), then drifted to SET comprehensions (missing the `:` colon → `{expr for ...}` is a set, not a dict).
- **`row.name` trap (pandas):** `.name` is a reserved Series attribute returning the row's INDEX label, not the "name" column. Fails silently. Use `row["name"]`. Other columns (`row.email`, `row.month`) are fine as attributes.
- **`in` check BEFORE `[]` access:** `if today in person:` guards; `person[today]` raises `KeyError` if absent. User hit `KeyError: (7,9)` by doing `person[today]` on the line ABOVE the `if` guard — the risky lookup must live INSIDE the guard. (Their earlier `try/except KeyError` was also a valid alternative.)
- **Dynamic recipient (the whole point of extra-hard):** `to_addrs=birthday_person[1]` (email pulled from the matched row's value), not a hardcoded address. It "worked" hardcoded only because the one test person shared the user's own email.
- Value stored as a positional tuple `(name, email, month, day)` → access by index (`[0]`=name, `[1]`=email). Noted the tradeoff vs storing the whole `row` (which allows `row["name"]`).

## Random letter
- `num = random.randint(1, 3)` → `open(f"letter_templates/letter_{num}.txt")` → `.read().replace("[NAME]", name)`.

## Security / repo
- Credentials were hardcoded during dev, then scrubbed to `os.environ.get("EMAIL")` / `os.environ.get("PASSWORD")` before the FIRST commit (so never entered git history). Applies to both `main.py` and `challenge1.py`.
- Scripts now require `EMAIL`/`PASSWORD` env vars set to run.
- User agreed to revoke/rotate the exposed App Password on their end (it appeared in chat + on disk).
- Pushed to [[learning-github-repo]] on the day32 session; rebased over a Windows-PC commit.

Related: [[day31-flashy-flashcard-app]], [[day26]] (dict comprehension + iterrows), [[course-general]], [[feedback-step-then-review]].
