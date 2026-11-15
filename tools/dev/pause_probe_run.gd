extends Node
## Developer check: toggling Sound while paused must not change the menu's size or position,
## must not move the keyboard focus, and the label must follow (button click AND the N key).
## Run: godot --path . res://tools/dev/pause_probe.tscn   (add a window for screenshots in tools/shots/)

var _fails := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("  ok    " if ok else "  FAIL  "), what)
	if not ok:
		_fails += 1


func _shot(shot_name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://tools/shots/pause_%s.png" % shot_name))


func _btn(prefix: String) -> Button:
	for b: Button in PauseMenu.find_children("*", "Button", true, false):
		if b.text.begins_with(prefix) and b.is_visible_in_tree():
			return b
	return null


func _press(action: StringName) -> void:
	for pressed in [true, false]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await get_tree().process_frame
		await get_tree().process_frame


func _run() -> void:
	await get_tree().process_frame
	GameState.start_fresh_progress()
	MissionDirector.start_new_game()
	Sfx.set_muted(false)
	get_tree().change_scene_to_file("res://scenes/academy/academy_hub.tscn")
	await get_tree().create_timer(1.5).timeout
	await _finish_intro()
	print("[pause probe]")
	await _press(&"pause_menu")
	await get_tree().create_timer(0.5).timeout
	_check(get_tree().paused, "P pauses the game")
	var panel: Control = PauseMenu.get("_panel")
	var size_before := panel.size
	var pos_before := panel.position
	_check(size_before.y > 100.0, "the menu is a normal size when it opens (%s)" % size_before)
	var sound := _btn("Sound")
	sound.grab_focus()
	var focus_before := get_viewport().gui_get_focus_owner()
	await _shot("1_before")

	for i in 6:
		var was := Sfx.muted
		sound.pressed.emit()
		await get_tree().create_timer(0.08).timeout
		_check(Sfx.muted != was, "clicking Sound flips it (now %s)" % ("off" if Sfx.muted else "on"))
		_check(panel.size == size_before and panel.position == pos_before, "menu size and position unchanged after click %d (%s)" % [i + 1, panel.size])
		_check(get_viewport().gui_get_focus_owner() == focus_before, "keyboard focus stays on the Sound button")
		_check(_btn("Sound") == sound and sound.text == "Sound: %s" % ("off" if Sfx.muted else "on"), "the label matches the setting (%s)" % sound.text)
		if i == 0:
			await _shot("2_after_toggle")
	for i in 4:
		var was := Sfx.muted
		await _press(&"mute")
		await get_tree().create_timer(0.08).timeout
		_check(Sfx.muted != was, "the N key flips Sound while paused (now %s)" % ("off" if Sfx.muted else "on"))
		_check(panel.size == size_before and panel.position == pos_before, "menu size and position unchanged after N %d" % (i + 1))
		_check(sound.text == "Sound: %s" % ("off" if Sfx.muted else "on"), "the label follows the N key (%s)" % sound.text)
	_check(get_viewport().gui_get_focus_owner() == focus_before, "focus still on Sound after the N key")
	# The menu still responds afterwards.
	_btn("Help").pressed.emit()
	await get_tree().create_timer(0.2).timeout
	_check(PauseMenu.get("_page") == "help", "the menu still navigates after toggling")
	await _press(&"ui_cancel")
	await get_tree().create_timer(0.2).timeout
	_check(PauseMenu.get("_page") == "home" and panel.size == size_before, "back to the home page at the same size")
	await _press(&"ui_cancel")
	_check(not get_tree().paused, "Esc resumes")
	Sfx.set_muted(false)
	print("PAUSE PROBE: %s" % ("PASS" if _fails == 0 else "%d FAILED" % _fails))
	get_tree().quit(1 if _fails > 0 else 0)


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
