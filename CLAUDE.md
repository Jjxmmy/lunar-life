# Lunar Life — file map (read this first, open only the files you need)

Godot 4.7, GDScript (tabs), 480x270, nearest filter. Work branch: `lunar-life-slice` (main is stale — don't merge into it without asking Aryan).
Godot: `/Users/aryanpatel/Downloads/Godot.app/Contents/MacOS/Godot`. New PNGs need `--headless --path . --import` once.
Test: `Godot --headless --path . res://tools/playtest.tscn -- rover=0 choice=2 late=0 speed=4` (drop --headless for screenshots in tools/shots/).

| Mechanic / area | File(s) |
|---|---|
| Player movement, WASD, walk/turn/idle animations (Kareem) | scripts/player/player.gd, assets/art/characters/astronaut/ |
| Input bindings (move_*, interact, pause P, mute M) | scripts/autoload/controls.gd |
| Mission flow & stages (briefing → training → checks → storm alert → shelter → debrief) | scripts/autoload/mission_director.gd, data/nasa/sep_replay_config.json |
| Power, battery, loads, daylight, science progress | scripts/autoload/resource_sim.gd, data/loads/*.tres |
| Player name, suit colour, certificates, scores | scripts/autoload/game_state.gd |
| Dialogue box / typewriter | scripts/autoload/dialogue.gd, data/npcs/*.tres |
| Scene switching & fades | scripts/autoload/scene_router.gd |
| Pause menu, task log (Jimmy) | scripts/autoload/pause_menu.gd, task_log.gd |
| Sound effects | scripts/autoload/sfx.gd |
| Global signals | scripts/autoload/event_bus.gd |
| Character creator | scripts/ui/create_astronaut.gd, assets/shaders/suit_tint.gdshader |
| Academy hub + mentor | scripts/academy/academy_hub.gd, scripts/npc/npc.gd |
| Power console minigame | scripts/minigames/power_console.gd |
| Outpost map, stations, crew, storm visuals, debrief | scripts/outpost/outpost.gd, scripts/world/station.gd, scripts/npc/crew_member.gd, scripts/world/habitat_camera.gd |
| Shelter choice panel | scripts/ui/choice_panel.gd |
| NASA DONKI SEP data (cached) | data/nasa/donki_sep_cached.json |
| Automated playtest | tools/playtest.gd, tools/playtest_driver.gd |
| Credits / docs / briefs | docs/CREDITS.md, docs/DEVELOPMENT-BATCH.md, docs/handoff/ |

Workflow: `git fetch` → `git diff --stat HEAD origin/lunar-life-slice` → pull → edit only the mapped files → run the playtest → commit only the changed paths → push.
