---
name: day26
description: "Day 26 - List/Dict Comprehensions and pandas DataFrame iteration, completed"
metadata: 
  node_type: memory
  type: project
  originSessionId: 57b7474b-ee46-477c-a5ea-fcb59d4d8fc3
---

Day 26 covers list comprehensions, dictionary comprehensions, and looping through pandas DataFrames.

**Topics completed:**
- List comprehension with `int()` conversion and `%` modulo filter
- Reading files with `with open()`, `.strip()` in list comprehension
- Finding common elements between two lists using `if n in list`
- Dict comprehension: filtered students by score (`>= 60`) using `.items()`
- Dict comprehension: word lengths from a sentence using `.split()` and `len()`
- Dict comprehension: Celsius to Fahrenheit conversion using `(temp * 9/5) + 32`
- pandas `DataFrame` from dict, looping with `.iterrows()`, filtering by row value

**Key patterns learned:**
- `{key: value for (key, value) in dict.items()}` — transform values
- `{key: value for (key, value) in dict.items() if condition}` — filter
- Formula goes in the value slot, `for` part only unpacks
- `student_data_frame.iterrows()` yields `(index, row)` tuples
- Access row fields as `row.student`, `row.score`

**Capstone project (NATO Alphabet):**
- Read CSV with `pandas.read_csv()`, build dict with `{row.letter: row.code for (index, row) in df.iterrows()}`
- List comprehension to map user input letters to NATO codes: `[l_c_dict[letter.upper()] for letter in user_input]`
- Common mistake: unpacking `iterrows()` as `(letter, code)` instead of `(index, row)`
- Common mistake: calling a string variable with `()` (TypeError: 'str' object is not callable)

**Why:** Understanding comprehensions as a compact alternative to loops; pandas iteration for data processing.
**How to apply:** Student is comfortable with dict comprehensions and pandas iterrows(); ready for Day 27.
