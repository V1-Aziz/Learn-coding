# Birthday Wisher — Extra Hard (Steps)

A guide, not the answers. Do the steps in order.

## Step 1 — Data (mostly done)
- `birthdays.csv` already has your row (`Abdulaziz, ..., 2003, 7, 9`) — that date is **today**, so it'll trigger. Good for testing.
- Delete the `[Fill this in!]` line, or add a couple more people.

## Step 2 — Read CSV + build a lookup
- Load `birthdays.csv` with `pandas.read_csv()` → it **already returns a DataFrame** (no need to wrap it again).
- Build a dict keyed by a `(month, day)` **tuple**, value = the whole `row`:
  ```
  { (row.month, row.day): row for (index, row) in data.iterrows() }
  ```
- Get today's date with `datetime.datetime.now()`, then pull `.month` and `.day`.

## Step 3 — Is today a birthday?
- Make today's `(month, day)` tuple.
- Check if that tuple is a **key** in your dict.
- If yes, `your_dict[(month, day)]` hands you that person's `row` (name + email inside).

## Step 4 — Pick + personalize a letter
- Random-pick a file from `letter_templates/`. The names are `letter_1.txt`..`letter_3.txt`, so build the filename with `random.randint(1, 3)`.
- Open the chosen letter, `.read()` its contents.
- Replace `[NAME]` with the person's name using `.replace("[NAME]", ...)`.

## Step 5 — Send the email
- Reuse your working Gmail SMTP code (server `smtp.gmail.com`, `starttls()`, `login()`).
- Send the personalized letter to **that person's email** (from the row), subject like `Happy Birthday!`.

---

## ⚠️ Gotchas
- **Key must be a `(month, day)` tuple** — a tuple is the one object that holds two values as a single key.
- **`row.name` does NOT give the name column.** In pandas, `.name` is a reserved attribute that returns the row's index label. Use **`row["name"]`** instead. (`row.email`, `row.month`, `row.day` as attributes are fine.)
- `.weekday()`/`.month`/`.day` are **read off** a datetime object — they return values, they don't take one.
- Keep credentials out of the file before pushing to GitHub (App Password is live in the code).
