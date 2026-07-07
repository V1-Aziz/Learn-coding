---
name: Day 20 - Snake Game (Part 1)
description: Building the Snake Game using Turtle — segments, movement loop, and screen setup
type: project
originSessionId: b97f0930-9261-4e9a-bb7c-6218622fba81
---
Day 20 is the start of a multi-day Snake Game project using Turtle graphics.

**Topics covered:**
- Setting up a black 600x600 screen with `screen.tracer(0)` for manual updates
- Creating snake segments as white square Turtles at start positions `[(0,0), (-20,0), (-40,0)]`
- Game loop with `screen.update()` and `time.sleep(0.1)`
- Moving each segment forward each tick (early/basic movement — segments don't follow each other yet)

**Status:** In progress (basic snake rendering and movement only, no following logic, no food, no collision yet)

**Why:** This is Day 1 of 2 for the Snake Game — Day 21 will add proper snake body following, food, and collision detection.

**How to apply:** When continuing this project, pick up from adding proper segment-following movement (each segment moves to the position of the one ahead of it).
