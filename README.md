# Lunar Life

**Junior Astronaut Mission Trainer** for the 2026 NASA Space Apps Challenge.
Team: Kareem Dahrouj, Aryan Patel, Jimmy Lam.

You are a new crew member at a research outpost near the Moon's South Pole. Over a **five-day
mission** you learn what it takes to become an astronaut, keep the outpost's power and greenhouse
running, run real space-farming experiments, and on Day 5 get everyone behind the storm shelter
when a solar particle storm arrives. The storm is a replay of a real NASA DONKI record (10 May 2024).

## Run it
1. Open Godot 4.7 (4.7.2 was used), choose **Import**, and pick `project.godot` in this folder.
2. Press **F5**.

## Controls
| Key | Action |
| --- | --- |
| WASD / arrows (or gamepad stick) | Walk. Two keys at once walks diagonally. |
| E / Space / Enter (gamepad A) | Talk, use, next line. Every story screen waits for this key. |
| Hold E | Crank open the storm-shelter hatch. |
| M | Map and waypoints. |
| N | Sound on / off. |
| Esc / P | Pause: field notes, tasks, help, sound. |

## The five-day mission (a first run takes about 25 minutes; this is an estimate, not a timed playtest)
Each outpost day runs: **morning → station tasks → a learning activity → evening log at the comms desk →
sleep in a sleep pod**. Battery, crops and science carry over from day to day; the crops visibly grow.
The HUD shows "Day N of 5".

1. **Day 1 — Academy: becoming an astronaut.** Intro slides, Commander Okafor's briefing, then
   sort real NASA selection requirements from myths. Capture cargo with the robotic-arm trainer
   (plus a quiz on astronaut training) and earn Engineer Rivera's power-console certificate.
2. **Day 2 — Arrival: power and living.** Morning power and greenhouse checks, plant the plant pillows
   with Dr. Tanaka, and a crew health check on the exercise bike (predict what low gravity does to bones).
3. **Day 3 — Space farming science.** Predict, then watch a light-recipe experiment grow; sort Earth soil
   from lunar regolith; taste the first harvest and learn the history of NASA's Veggie unit.
4. **Day 4 — Space weather watch.** Sort a DONKI-style feed of solar events, then a shelter drill
   (hold E on the hatch, step inside - no penalty).
5. **Day 5 — Last day of the rotation.** A routine morning, then the radiation alert: a short, skippable
   danger briefing (what a solar particle event is, why the Moon has no shield, why mass protects, how
   warnings work), the run to the shelter and the shelter power plan.
6. **Mission report** — the storm day's battery chart and three star ratings (crew safety, power,
   food + science). Try again restarts from the morning of Day 5.

Learning is interactive: quizzes and sorting with instant feedback, predict-then-reveal, and two hands-on
minigames. Fifteen **field notes** unlock as you play and are the "read more" layer: the real fact, how the
game simplifies it, and its source.

## What is real and what is simplified
- Real: the DONKI solar-energetic-particle record, the facts in the field notes (sources in `CREDITS.md`).
- Simplified: exposure, battery, power and time are game units. The record is a detection near Earth,
  not a dose at a lunar outpost. The sunlight shadow pattern is invented.
  The game says so on the report's **Sources** page and in the last field note.

## For developers
- Everything is built in code; scenes are one node with a script. Autoloads are listed in `project.godot`.
- Floor plans live in `scripts/outpost/outpost_layout.gd` and `scripts/academy/academy_layout.gd`.
  The room art is painted from those files: `python3 tools/art/paint_world.py` and `tools/art/paint_academy.py`.
- Sound is made by `python3 tools/audio/make_audio.py`.
- Automatic playthrough of all five days with about 345 checks:
  `godot --headless --path . res://tools/playtest.tscn -- speed=3`
  (options: `rover=0|1 choice=0|1|2 late=N`). Screenshots from the last rendered run are in `tools/shots/`.
- The day plan is `data/mission/days.json`; learning activities are `data/learning/activities.json`.
- `python3 tools/dev/check_layout.py` checks that furniture never blocks a door, station or route.
- `tools/dev/day_table.tscn` prints five-day outcomes per power habit; `tools/dev/strategy_table.tscn`
  prints storm strategies. Night length and star thresholds were set from them.
- What changed in the five-day build and how to test it: `docs/FIVE-DAY-BATCH.md`.
