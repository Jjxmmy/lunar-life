# Five-day mission build — changelog and how to test

Branch `five-day-mission`, built on `main` at `c840670` (Kareem's refined build plus the
navigation / pause-menu fixes from `bugfix-nav-pause`).

## What changed, by feedback item
1. **Five-day mission** — `MissionDirector` keeps a `day` counter (1–5) inside the existing
   stage machine. Day 1 is the academy (BRIEFING → GRADUATED). Days 2–5 run in the CHECKS stage
   with their tasks read from `data/mission/days.json`. Each day: tasks → evening log at the comms
   desk → sleep in a sleep pod. Sleep simulates `night_hours` (12) and then skips the rest period,
   so every morning starts at the same point of the sunlight pattern. The alert only starts once
   Day 5's tasks are done. The HUD and task log show "Day N of 5". *Try again* restores the saved
   Day 5 morning (`retry_storm()`).
2. **Interactive learning** — `scripts/learning/learning_activity.gd` runs quizzes,
   predict-then-reveal and sort activities from `data/learning/activities.json`, with instant
   feedback and a reason for every answer. Escape gives up without completing anything. There are
   two hands-on minigames: `scripts/minigames/arm_drill.gd` (Canadarm-style capture, Day 1) and
   `scripts/minigames/grow_experiment.gd` (light-recipe trays, Day 3).
3. **Becoming an astronaut and space farming** — selection requirements, training (NBL, T-38,
   survival, geology, robotics), bone and muscle loss, plant pillows and wicking, red/blue/green
   LED recipes, Outredgeous lettuce (10 Aug 2015), regolith vs soil (2022 Apollo-sample study).
   There are five new field notes. Every source is in `docs/CREDITS.md`.
4. **Danger cutscene** — `mission_cinematic.gd` has a `mode = "storm"` with four slides, under
   30 seconds, E to advance, Esc to skip, and the storm clock paused. It keeps the honest framing:
   DONKI records events near Earth, not a dose on the Moon.
5. **Navigation arrows through the player** — fixed by Kareem on `bugfix-nav-pause` and merged
   before this work.
6. **Sound toggle breaking the pause menu** — fixed by Kareem on `bugfix-nav-pause`. The playtest
   still checks size, focus and label after toggling.
7. **Furniture** — lockers, suit rack, exercise bike, comms desk, two sleep pods, plant shelf,
   galley table, med cot and cable trays (outpost), plus the robotics trainer, a suit rack and a
   study table (academy). Each piece is a layout constant plus a blocker, painted by
   `tools/art/paint_world.py` / `paint_academy.py`. `tools/dev/check_layout.py` flood-fills both
   maps and fails if any spot, door or crew route is blocked.
   The outpost "beds" were always grow beds, so the crew now sleeps in corridor sleep pods.

## Scoring
The mission report rates the **storm day** (`ResourceSim.start_rating_window()` on Day 5
morning). Battery, crop health and science carry over from Days 2–4, so habits matter:

| Strategy (playtest args) | Stars (safety + power + harvest) |
| --- | --- |
| Rover paused, full lights, pause both in shelter (`rover=0 choice=2`) | 3 + 3 + 3 |
| Rover charging left on every day (`rover=1 choice=0`) | 3 + 3 + 0 (crops wilt from overnight load shedding) |
| Late to the shelter, science kept on (`rover=0 choice=1 late=3`) | 2 + 0 + 3 |

## How to test
```
godot --headless --path . --import
godot --headless --path . res://tools/playtest.tscn -- speed=3
godot --headless --path . res://tools/playtest.tscn -- speed=3 rover=1 choice=0
godot --headless --path . res://tools/playtest.tscn -- speed=3 choice=1 late=3
godot --path . res://tools/playtest.tscn -- speed=3          # rendered: screenshots in tools/shots/
python3 tools/dev/check_layout.py                            # needs numpy (same as the painters)
godot --headless --path . res://tools/dev/day_table.tscn     # five-day balance table
```
On 2026-11-15 all three playtest runs passed 345 of 345 checks, and the layout check passed.

## Known gaps
- Run time: about 25 minutes for a first run is an estimate from the content, not a timed human playtest.
- The playtest answers every activity with the first option, so it checks the flow, not the answer keys.
- Speed 4 is too fast for the playtest's walking bot. Use speed 3.
- The arm drill and the experiment take keyboard / gamepad input. Mouse clicks only work in the panels.
