extends Control
## Animated title screen and entry point for the astronaut story.

var _stars: Array[Vector3] = []
var _continue_button: Button
var _title: Label
var _time := 0.0
var _lander: Control


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 47
	for i in 70:
		_stars.append(Vector3(rng.randf_range(8.0, 472.0), rng.randf_range(8.0, 258.0), rng.randf_range(0.4, 1.4)))
	var theme := Theme.new()
	theme.default_font_size = 9
	self.theme = theme
	_lander = Control.new()
	_lander.set_script(load("res://scripts/ui/title_lander.gd"))
	_lander.position = Vector2(20, 118)
	_lander.size = Vector2(48, 40)
	add_child(_lander)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.position = Vector2(-130, -112)
	column.size = Vector2(260, 224)
	column.add_theme_constant_override("separation", 6)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(column)
	_title = Label.new()
	_title.text = "LUNAR LIFE"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 25)
	_title.modulate = Color(0.72, 0.95, 0.91)
	column.add_child(_title)
	var subtitle := Label.new()
	subtitle.text = "A lunar research adventure"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.83, 0.86, 0.95)
	column.add_child(subtitle)
	_add_button(column, "New Game", _new_game)
	_continue_button = _add_button(column, "Continue", _continue_game)
	_continue_button.disabled = not GameState.has_save()
	_add_button(column, "Help / Controls", _show_help)
	_add_button(column, "About Lunar Life", _show_about)
	_add_button(column, "Quit Game", _confirm_quit)
	var hint := Label.new()
	hint.text = "WASD / arrows to move   •   E to interact"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate = Color(0.75, 0.79, 0.88, 0.8)
	column.add_child(hint)
	_title.modulate.a = 0.0
	var intro := create_tween()
	intro.tween_property(_title, "modulate:a", 1.0, 1.0)
	column.get_child(2).grab_focus.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if is_instance_valid(_title):
		_title.scale = Vector2.ONE * (1.0 + sin(_time * 1.4) * 0.025)


func _draw() -> void:
	_draw_space()


func _draw_space() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("080d20"))
	for i in _stars.size():
		var star := _stars[i]
		var twinkle := 0.45 + 0.45 * absf(sin(_time * star.z + float(i)))
		draw_rect(Rect2(star.x, star.y, 1.5, 1.5), Color(0.76, 0.88, 1.0, twinkle))
	var moon := Vector2(size.x * 0.78, size.y * 0.62)
	draw_circle(moon, 71, Color("727d9b"))
	draw_circle(moon + Vector2(-18, -20), 13, Color("626d89"))
	draw_circle(moon + Vector2(26, 8), 8, Color("626d89"))
	draw_circle(moon + Vector2(-30, 25), 6, Color("626d89"))
	draw_circle(Vector2(size.x * 0.18, size.y * 0.24), 18, Color("4e9cc4"))
	draw_arc(moon, 73, 3.55, 5.8, 48, Color("d1d6e8", 0.7), 1.0)


func _add_button(parent: VBoxContainer, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(220, 23)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _new_game() -> void:
	GameState.start_fresh_progress()
	MissionDirector.start_new_game()
	SceneRouter.go_to(&"create_astronaut")


func _continue_game() -> void:
	if GameState.load_progress():
		SceneRouter.go_to(&"academy_hub")


func _show_help() -> void:
	ChoicePanel.open(self, "FIELD GUIDE", "WASD or arrow keys: walk. E, Space or Enter: interact and advance dialogue. Esc: close a panel or open the pause menu. M: map. Follow the objective list and waypoint markers. During the solar particle alert, reach the marked shelter and choose how to conserve power.", PackedStringArray(["Got it"]))


func _show_about() -> void:
	ChoicePanel.open(self, "ABOUT LUNAR LIFE", "An educational astronaut adventure about training, habitat systems, resource choices and lunar space weather. NASA information is presented as real mission context. Gameplay time, exposure units and resource outcomes are simplified simulations.", PackedStringArray(["Back"]))


func _confirm_quit() -> void:
	var panel := ChoicePanel.open(self, "LEAVE THE MOON?", "Are you sure you want to quit Lunar Life?", PackedStringArray(["Keep exploring", "Quit game"]))
	panel.chosen.connect(func(index: int) -> void:
		if index == 1:
			get_tree().quit())
