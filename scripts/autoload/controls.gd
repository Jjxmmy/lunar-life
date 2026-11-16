extends Node
## Controls — registers the game's input actions in code (autoload).
## Done here instead of project.godot so the list is easy to read and merge.
##   move_left / move_right / move_up / move_down : WASD, arrow keys, d-pad or left stick
##   interact   : E, Space or Enter (hold it for heavy hatches), or the bottom face button
##   pause_menu : P or Start        map_toggle : M or the top face button        mute : N


func _ready() -> void:
	_add(&"move_left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_add(&"move_right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_add(&"move_up", [KEY_W, KEY_UP], JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0)
	_add(&"move_down", [KEY_S, KEY_DOWN], JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_add(&"interact", [KEY_E, KEY_SPACE, KEY_ENTER], JOY_BUTTON_A)
	# Menus use ui_accept: let E press buttons too, so "press E" works everywhere.
	_add(&"ui_accept", [KEY_E])
	_add(&"pause_menu", [KEY_P], JOY_BUTTON_START)
	_add(&"mute", [KEY_N])
	_add(&"map_toggle", [KEY_M], JOY_BUTTON_Y)


func _add(action: StringName, keys: Array, button: int = -1, axis: int = -1, axis_sign: float = 0.0) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.35)
	for key: Key in keys:
		# Bind both the physical key and the key's letter: some browsers (the web build)
		# don't always report a physical key code, so the letter keeps controls working.
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action, ev)
		var by_letter := InputEventKey.new()
		by_letter.keycode = key
		InputMap.action_add_event(action, by_letter)
	if button >= 0:
		var pad := InputEventJoypadButton.new()
		pad.button_index = button as JoyButton
		InputMap.action_add_event(action, pad)
	if axis >= 0:
		var stick := InputEventJoypadMotion.new()
		stick.axis = axis as JoyAxis
		stick.axis_value = axis_sign
		InputMap.action_add_event(action, stick)
