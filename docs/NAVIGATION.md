# Lunar Life navigation

The academy and outpost now have a live minimap and an expanded map with destination markers, descriptions and routes. The route uses AStarGrid2D, the scene floor rectangles and a collision probe sized for the astronaut. Markers for outpost crew follow their actual positions.

## Try it in Godot 4.7.2

1. Run the project, finish the briefing and click the minimap or press M.
2. Click Rivera or choose a destination from the dropdown. Zoom with the wheel or plus and minus. Drag to pan.
3. Close with M, Escape or Close. Follow the pulsing ground arrows. A manual waypoint clears on arrival. Reopen the map to replace or clear it or hide the arrows.
4. Open Pause → Tasks and track a task. A task waypoint stays active until the objective is completed and follows the next mentor or academy area when applicable.
5. After earning the certificate, select Lunar outpost on the academy map, then follow the arrows to the hatch and interact. The selected destination follows you through travel. Press N to mute or unmute.

Run the repository's automated playthrough with `godot --headless --path . res://tools/playtest.tscn`.

## Limits

Transit guidance uses the existing hatches and access rules. During an alert the outpost hatch closes, and cross-facility routes wait until transit is available. The map displays the current facility. The routing grid is rebuilt when entering a scene and routes refresh while moving. Routes assume the current static layout. Moving crew are nonblocking, and future moving blockers would need grid updates.
