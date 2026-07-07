---
name: day-21-class-inheritance-snake-game-part-2
description: "Day 21 — Class inheritance + Snake Game Part 2 (refactor to classes, score, collisions, growth)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6eb4cdae-4ce4-4397-99f8-a560f21c21b4
---

Day 21 covered class inheritance, then refactored the Snake Game from Day 20 into proper classes with all final features.

**Inheritance section (Class_Inheritance.py):**
- Parent class (`Animal`) with `__init__` and `breathe()` method
- Child class (`Fish(Animal)`) inheriting from parent
- `super().__init__()` to inherit parent attributes
- Method overriding — replace vs. extend via `super().method()`
- Adding child-only methods (`swim()`)
- Concepts: DRY, "is-a" relationships, polymorphism, extending library classes

**Snake Game Part 2 — all features built:**
- `Snake` class (snake.py): segments list, head reference, move logic, direction methods, `add_segment(position)` helper, `extend()` method
- `Food` class (food.py): inherits Turtle, `refresh()` method called in `__init__` for random initial spawn and after eat
- `Scoreboard` class (scoreboard.py): inherits Turtle, `update_score()` with clear-then-write pattern, `increase_score()`, `game_over()` displaying "Game over" at center
- Wall collision: check `head.xcor()` and `head.ycor()` against ±280
- Tail collision: loop through `self.segements[1:]` slice and check `head.distance(segment) < 10`
- Game over: `game_on = False` + `scoreboard.game_over()`

**Key learnings:**
- Why double-print on food collision: snake moves 20px/tick, collision check is <15px, so two consecutive head positions can both be within range. Refresh fixes by relocating food.
- Loose coupling: Snake doesn't import Food — main.py coordinates between them. User arrived at this insight independently.
- Clean code refactor: extracted `add_segment(position)` so `create_snake()` and `extend()` both use it (DRY).

**Status:** Day 21 complete (2026-05-24).

**How to apply:** When starting Day 22, the Snake Game is fully working and serves as the reference for OOP refactoring patterns. Note: variable spelling `segements` (typo) is consistent throughout user's code — don't correct unless asked.

Related: [[day20]], [[course-general]], [[feedback-clear-questions]]
