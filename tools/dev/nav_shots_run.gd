extends Node
## Developer tool: walks the astronaut up, down, left and right with a waypoint set, in the
## academy and the outpost, and saves screenshots (chevrons and objective arrow visible).
## Run with a window:  godot --path . res://tools/dev/nav_shots.tscn   -> tools/shots/nav_*.png


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://tools/shots/nav_%s.png" % shot_name))


func _walk_and_shoot(scene_tag: String, start: Vector2, scale: float) -> void:
	var p := get_tree().get_first_node_in_group(&"player") as CharacterBody2D
	for dir: Array in [["up", &"move_up"], ["down", &"move_down"], ["left", &"move_left"], ["right", &"move_right"]]:
		p.global_position = start * scale
		await get_tree().create_timer(0.3).timeout
		Input.action_press(dir[1])
		await get_tree().create_timer(0.35).timeout
		await _shot("%s_%s" % [scene_tag, dir[0]])
		Input.action_release(dir[1])
		await get_tree().create_timer(0.15).timeout


func _run() -> void:
	await get_tree().process_frame
	GameState.start_fresh_progress()
	MissionDirector.start_new_game()
	get_tree().change_scene_to_file("res://scenes/academy/academy_hub.tscn")
	await get_tree().create_timer(1.5).timeout
	await _finish_intro()
	MapManager.set_waypoint("Academy", "weather")
	await _walk_and_shoot("academy", Vector2(384, 280), 1.0)

	MissionDirector.stage = MissionDirector.Stage.CHECKS
	ResourceSim.reset_state(4, 20.0, MissionDirector.TRAINING_PATTERN)
	get_tree().change_scene_to_file("res://scenes/outpost/outpost.tscn")
	# Let the touchdown scene play out and hand control back.
	var waited := 0.0
	while (MissionDirector.ui_open or not get_tree().get_nodes_in_group(&"fullscreen_story").is_empty() or waited < 2.0) and waited < 20.0:
		await get_tree().create_timer(0.25).timeout
		waited += 0.25
	await get_tree().create_timer(0.6).timeout
	MapManager.set_waypoint("Outpost", "crops")
	await _walk_and_shoot("outpost", Vector2(240, 232), 1.5)
	get_tree().quit()


## Press E through the intro slides and the commander's briefing, as a player would.
func _finish_intro() -> void:
	var guard := 0
	while (get_tree().current_scene.find_child("MissionCinematic", true, false) != null or Dialogue.is_active or MissionDirector.ui_open) and guard < 60:
		for pressed in [true, false]:
			var ev := InputEventAction.new()
			ev.action = &"interact"
			ev.pressed = pressed
			Input.parse_input_event(ev)
			await get_tree().process_frame
			await get_tree().process_frame
		await get_tree().create_timer(0.35).timeout
		guard += 1
