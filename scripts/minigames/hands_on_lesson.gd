extends CanvasLayer
## Short hands-on lessons. Leaving never emits completion.
signal finished
var kind: StringName = &"plant"
var autopilot := false
var _canvas: Control
var _time := 0.0
var _step := 0
var _score := 0
var _water := 0.0
var _mistakes := 0
var _result := false

func _ready() -> void:
	layer = 40
	MissionDirector.push_ui()
	_canvas = Control.new()
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_activity)
	add_child(_canvas)

func _exit_tree() -> void:
	MissionDirector.pop_ui()

func _process(delta: float) -> void:
	_time += delta
	if not _result and kind == &"plant" and _step == 1:
		if Input.is_action_pressed(&"interact") or autopilot:
			_water = minf(100.0, _water + delta * 28.0)
		if autopilot and _water >= 55.0:
			_act()
	elif autopilot and not _result:
		if kind == &"health":
			if absf(sin(_time * 2.0)) < 0.12 and _time > float(_score) * 0.7:
				_act()
		elif fmod(_time, 0.8) < delta:
			_act()
	elif autopilot and _result:
		finished.emit()
		queue_free()
	_canvas.queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
	elif event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _result:
			finished.emit()
			queue_free()
		elif kind != &"plant" or _step != 1:
			_act()
	elif event.is_action_released(&"interact") and kind == &"plant" and _step == 1:
		get_viewport().set_input_as_handled()
		_act()

func _act() -> void:
	if kind == &"health":
		if absf(sin(_time * 2.0)) < 0.3:
			_score += 1
			_time += 0.35
			Sfx.play(&"confirm")
		else:
			_mistakes += 1
		_result = _score >= 8
	else:
		if _step == 1 and (_water < 40.0 or _water > 70.0):
			_mistakes += 1
			_water = 0.0
			return
		_step += 1
		Sfx.play(&"confirm")
		_result = _step >= 3

func _draw_activity() -> void:
	_canvas.draw_rect(Rect2(0, 0, 480, 270), UiKit.INK)
	var title := "SPACE GARDEN" if kind == &"plant" else "BONE BUILDER"
	UiKit.draw_text(_canvas, Vector2(24, 28), title, "title", UiKit.AMBER)
	var why := "Why: roots need steady water and light." if kind == &"plant" else "Why: exercise helps keep muscles and bones strong."
	UiKit.draw_text(_canvas, Vector2(24, 48), why, "small", UiKit.TEXT)
	if _result:
		UiKit.draw_text(_canvas, Vector2(24, 90), "%d STARS - WELL DONE!" % maxi(1, 3 - _mistakes / 3), "title", UiKit.GREEN)
		var learned := "Pillows hold roots. Wicks bring water to them." if kind == &"plant" else "Regular exercise helps astronauts stay strong."
		UiKit.draw_text(_canvas, Vector2(24, 125), "You learned: " + learned, "small", UiKit.TEXT)
		UiKit.draw_text(_canvas, Vector2(24, 155), "E / confirm: finish    Esc: leave", "small", UiKit.TEXT)
		return
	if kind == &"plant":
		var instructions := ["1. Press E to tuck a seed into its pillow.", "2. Hold E to water. Release in the marked zone.", "3. Press E to test red and blue grow lights."]
		UiKit.draw_text(_canvas, Vector2(24, 75), instructions[mini(_step, 2)], "small", UiKit.TEXT)
		_canvas.draw_rect(Rect2(200, 150, 100, 48), UiKit.AMBER_DIM)
		_canvas.draw_rect(Rect2(90, 110, 40, 90), UiKit.PANEL)
		_canvas.draw_rect(Rect2(92, 198 - _water * 0.86, 36, _water * 0.86), UiKit.TEAL)
		_canvas.draw_rect(Rect2(88, 138, 44, 27), UiKit.GREEN, false, 2)
		_canvas.draw_line(Vector2(130, 180), Vector2(200, 170), UiKit.TEAL, 3)
		if _step > 0:
			_canvas.draw_circle(Vector2(245, 165), 5, UiKit.GREEN)
		if _step == 2:
			_canvas.draw_rect(Rect2(205, 100, 90, 6), UiKit.VIOLET)
		UiKit.draw_text(_canvas, Vector2(24, 225), "Reservoir -> wick -> roots. Green outline = enough water.", "small", UiKit.TEXT)
	else:
		UiKit.draw_text(_canvas, Vector2(24, 75), "Tap E when the moving dot reaches the center box.", "small", UiKit.TEXT)
		_canvas.draw_line(Vector2(80, 145), Vector2(400, 145), UiKit.TEXT_DIM, 3)
		_canvas.draw_rect(Rect2(216, 130, 48, 30), UiKit.GREEN, false, 2)
		_canvas.draw_circle(Vector2(240 + sin(_time * 2.0) * 160, 145), 7, UiKit.AMBER)
		UiKit.draw_text(_canvas, Vector2(24, 200), "Good beats: %d / 8" % _score, "title", UiKit.TEAL)
		UiKit.draw_text(_canvas, Vector2(24, 225), "Training game: real health changes over much longer times.", "small", UiKit.TEXT)
	UiKit.draw_text(_canvas, Vector2(24, 252), "Esc: leave and try again", "small", UiKit.TEXT_DIM)
