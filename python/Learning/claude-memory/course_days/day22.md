---
name: day22-pong-game
description: "Day 22 - Built a complete Pong game with paddles, ball physics, scoreboard, and progressive speed increase"
metadata: 
  node_type: memory
  type: project
  originSessionId: ed16cc5d-d63b-4307-9b32-16c8a460fe8c
---

# Day 22 — Pong Game (Completed)

Status: ✅ Completed 2026-05-25

## What was built
A two-player Pong game with the following files:
- `main.py` — screen setup, game loop, keyboard listeners, collision orchestration
- `padel.py` — `Padel` class inheriting from `Turtle` (note: user spelled it "Padel" not "Paddle")
- `ball.py` — `Ball` class with `move_x`/`move_y`/`move_speed` state, bounce/reset/speed methods
- `scoreboard.py` — `Scoreboard` class using `clear()` + `write()` to redraw scores each update

## Concepts practiced
- Class inheritance from `Turtle` (continued from [[day21-class-inheritance-snake-game-part-2]])
- **Constructor parameters** — passing position to `Padel.__init__(self, position)` so the same class can spawn left and right paddles. User initially tried "create then `.goto()`" approach; was nudged to the more idiomatic constructor-parameter approach and refactored.
- Compound assignment (`*=`, `+=`) — including hitting the `=+` vs `+=` typo bug in `r_point()` (set to 1 instead of incrementing)
- `turtle.distance()` for collision detection
- Operator precedence: `and` binds tighter than `or`. User asked why we didn't use `elif` instead of long single-`if`; refactored to `elif` for clarity.
- `tracer(0)` + manual `screen.update()` + `time.sleep()` game loop pattern
- Dynamic difficulty via `ball.move_speed *= 0.9` on paddle hits, reset to `0.1` on miss

## Bugs the user debugged
1. Mixed inheritance + composition in `Padel` (had `class Padel(Turtle):` AND `padel = Turtle()` inside `__init__`)
2. `super.__init__()` instead of `super().__init__()`, and putting it inside `up()`/`down()` instead of `__init__`
3. Using `forward()`/`back()` for vertical movement (turtle faces east by default — moves horizontally)
4. Forgot `screen.listen()` initially
5. Missing `bounce_x()` in `reset_position()` (ball kept going same direction after reset)
6. `=+` vs `+=` typo in `r_point()` — only triggered when right player scored multiple times
7. Edited wrong file (Day 21's instead of Day 22's) — easy mistake to make

## Controls
- Left paddle: Up / Down arrows
- Right paddle: W / S

## Key teaching moments
- Why constructor parameters > post-construction setters (object born in final state, encapsulation, callers don't need to remember setup order)
- Why we use `goto(x, ycor()+20)` instead of `forward(20)` for vertical movement
- Why call `update_score()` from inside `l_point()`/`r_point()` (so caller doesn't have to remember to refresh)
- Why `clear()` before `write()` in `update_score()` (otherwise text stacks on itself)
