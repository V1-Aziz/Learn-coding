---
name: day25-csv-pandas
description: "Day 25 - Working with CSV data and the pandas library, completed"
metadata: 
  node_type: memory
  type: project
  originSessionId: bbba4980-6fc1-4629-9898-02702c7c29f2
---

# Day 25 - Working with CSV Data and pandas

## Files
- `weather_data.csv` — days, temps, conditions (Mon–Sun)
- `data.csv` — students and scores (Amy, James, Angela)
- `2018_Central_Park_Squirrel_Census_-_Squirrel_Data.csv` — real squirrel census data
- `new_data.csv` — output: fur color counts
- `main.py` — practice code

## Key concepts covered
- Reading CSV manually with `open()` + `readlines()` — returns list of strings with `\n`; use `.strip()` on each item individually
- `csv.reader()` — iterates over rows as lists
- `pandas.read_csv("file.csv")` — returns a DataFrame
- Accessing a column: `data["col"]` or `data.col` — returns a Series
- `.to_list()`, `.to_dict()` — convert Series to Python types
- `.mean()`, `.max()` — built-in pandas aggregation methods
- Filtering rows: `data[data.day == "Monday"]`
- Chaining: filter → extract column → apply formula (e.g. C to F conversion)
- `.value_counts()` — returns a Series with values as index and counts as values; already contains both, no need for `.unique()` separately
- `pandas.DataFrame(series)` — convert a Series directly into a DataFrame
- `.to_csv("file.csv")` — save DataFrame to a CSV file

## US States Game (main project)
- Turtle + pandas game: guess all 50 US states on a blank map
- `50_states.csv` — state name, x, y coordinates
- Used `data[data["state"] == answer]["x"].item()` to get coordinates
- `answer in series` checks index not values — must use `.to_list()` first
- `.title()` on input handles case sensitivity
- On "Exit": saves unguessed states to `states_to_learn.csv`
- Title uses f-string to show live score out of 50

## Status
Completed (including US States Game project).
