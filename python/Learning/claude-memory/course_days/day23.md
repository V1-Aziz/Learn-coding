---
name: day23-turtle-crossing
description: "Day 23 - Built Turtle Crossing game: player, car spawner with manager (not inherited), level scoreboard, game over"
metadata: 
  node_type: memory
  type: project
  originSessionId: b09638fd-26fc-449b-9aa0-a38713aad4f9
---

# Day 23 — Turtle Crossing Game (Completed)

Status: ✅ Completed 2026-06-02

## What was built
A frogger-style crossing game with four files:
- `main.py` — screen setup, game loop, key listener, collision + finish-line orchestration
- `player.py` — `Player(Turtle)` with `go_up`, `is_at_finish_line`, `go_to_start`
- `car_manager.py` — `CarManager` (plain class, NOT inheriting from Turtle) that spawns/tracks/moves cars
- `scoreboard.py` — `Scoreboard(Turtle)` showing "Level: N" top-left, "GAME OVER!" on crash

## Concepts practiced
- Inheritance vs composition — `Player` and `Scoreboard` inherit from `Turtle`, but `CarManager` is a **plain manager class** that creates/tracks turtle cars in `self.all_cars`. Key distinction: manager *uses* turtles, doesn't *behave as* one.
- Random spawning with probability gate (`randint(1, 6) == 1` for 1-in-6 chance per loop tick)
- `randint`, `choice` from `random` module
- Collision detection via `turtle.distance(other) < N`
- Level system: increase `car_speed += MOVE_INCREMENT` on each crossing
- Scoreboard pattern: `clear()` + `write()` to redraw without stacking text (same as [[day22-pong-game]])
- Bonus: user added `"w"` key as alternate to Up arrow, on their own initiative

## Bugs the user debugged
1. `class CarManager(Turtle):` — wrongly inherited from Turtle; manager should be plain class
2. `Turtle("square")` not assigned to a variable — created car was lost
3. Called `self.shapesize(...)`, `self.color(...)`, etc. on the **manager** instead of the new car (very common confusion — `self` inside a manager method ≠ the object being created)
4. `self.shapesize(stretch_len=1, stretch_wid=2)` — swapped wid/len making vertical not horizontal cars
5. `self.all_cars.append()` — empty append (forgot to pass `new_car`)
6. `goto(300, randint(-320, 250))` — y range went below the screen
7. `cars.backward(MOVE_INCREMENT)` instead of `cars.backward(self.car_speed)` — cars moved at the wrong (level-up) constant, not current speed
8. `move_cars` initially called `self.backward()` instead of `cars.backward(...)` — moving the manager, not the cars
9. **`=+` vs `+=` typo** in `level_up` (`self.car_speed =+ MOVE_INCREMENT`) — same bug pattern as [[day22-pong-game]]. User asked for full explanation this time; covered unary plus vs compound assignment.

## Key teaching moments
- **When NOT to inherit from Turtle**: a class that *manages* other turtles (CarManager) isn't itself a turtle. Compare to Player/Scoreboard which ARE turtles visually on screen.
- `=+` vs `+=`: `x =+ 3` parses as `x = +3` (unary plus, just means positive 3). Mnemonic: "equals comes second" in real compound operators (`+=`, `-=`, `*=`, `/=`).
- Why call methods on the *new object* (`new_car.color(...)`) instead of `self` inside a factory-style method.
- Why pass `self.car_speed` (current state) not `MOVE_INCREMENT` (the increment constant) when moving cars.

## Constants used
- `STARTING_POSITION = (0, -280)`, `MOVE_DISTANCE = 10`, `FINISH_LINE_Y = 280` (player)
- `STARTING_MOVE_DISTANCE = 5`, `MOVE_INCREMENT = 10` (cars)
- `COLORS = ["red", "orange", "yellow", "green", "blue", "purple"]`
- `FONT = ("Courier", 24, "normal")` (scoreboard)

## Controls
- Up arrow OR `w` — move player up
