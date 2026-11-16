extends "res://scripts/minigames/hands_on_lesson.gd"
## Day 3 microscope and harvest activities reuse the lesson lifecycle.
var _position := Vector2(110, 160)
var _choice := 0
var _finished := false
var _collected: Array[int] = []
var _astronaut: Texture2D = preload("res://assets/art/characters/astronaut/astronaut_front_idle.png")
var _feedback := ""
const TARGETS := [Vector2(170, 120), Vector2(300, 180), Vector2(365, 115)]

func _process(delta: float) -> void:
	_time += delta
	if _result:
		if autopilot:
			_finish_lesson()
	elif kind == &"harvest":
		var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		if autopilot:
			direction = (TARGETS[_score] - _position).normalized()
		_position = (_position + direction * delta * 85.0).clamp(Vector2(55, 100), Vector2(425, 205))
		if autopilot and _position.distance_to(TARGETS[_score]) < 14:
			_act()
	elif autopilot and fmod(_time, 0.7) < delta:
		if kind == &"regolith":
			_choice = _score % 3
		_act()
	_canvas.queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
	elif event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"move_left"):
		_choice = posmod(_choice - 1, 3)
	elif event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"move_right"):
		_choice = (_choice + 1) % 3
	elif event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _result:
			_finish_lesson()
		else:
			_act()

func _act() -> void:
	if _result or _finished:
		return
	match kind:
		&"regolith":
			if _choice == _score % 3:
				_score += 1
				_feedback = "Good observation! Look at the next sample."
			else:
				_feedback = "Try again: compare its shape with the labels."
			_result = _score >= 6
		&"harvest":
			for i in TARGETS.size():
				if i not in _collected and _position.distance_to(TARGETS[i]) < 22:
					_collected.append(i)
					_score += 1
					_feedback = "Ripe leaves collected for the galley!"
			_result = _score >= 3
	Sfx.play(&"confirm")

func _finish_lesson() -> void:
	if not _result or _finished:
		return
	_finished = true
	ResourceSim.science_progress += 3
	finished.emit()
	queue_free()

func _draw_activity() -> void:
	_canvas.draw_rect(Rect2(0, 0, 480, 270), UiKit.INK)
	var titles := {&"regolith":"DUST DETECTIVE", &"harvest":"FIRST HARVEST"}
	UiKit.draw_text(_canvas, Vector2(20, 26), titles.get(kind, "TRAINING"), "title", UiKit.AMBER)
	if _result:
		var facts := {&"regolith":"Moon dust differs from soil. Plants can grow, but struggle.", &"harvest":"Fresh leaves add variety to the crew's meals."}
		UiKit.draw_text(_canvas, Vector2(20, 95), "YOU LEARNED", "title", UiKit.GREEN)
		UiKit.draw_text(_canvas, Vector2(20, 120), facts[kind], "small", UiKit.TEXT)
		UiKit.draw_text(_canvas, Vector2(20, 220), "E: finish    Esc: leave without completion", "small", UiKit.TEXT)
		if kind == &"regolith":
			_canvas.draw_rect(Rect2(95, 180, 100, 8), UiKit.AMBER_DIM)
			_canvas.draw_rect(Rect2(285, 180, 100, 8), UiKit.AMBER_DIM)
			_canvas.draw_line(Vector2(145,180),Vector2(145,140),UiKit.GREEN,5)
			_canvas.draw_line(Vector2(335,180),Vector2(335,160),UiKit.AMBER,4)
			UiKit.draw_text(_canvas,Vector2(80,205),"Control: healthier", "small",UiKit.TEXT)
			UiKit.draw_text(_canvas,Vector2(265,205),"Regolith: stressed", "small",UiKit.TEXT)
		return
	match kind:
		&"regolith":
			UiKit.draw_text(_canvas, Vector2(20, 52), "Inspect the sample. Left/right selects a tray. E sorts it.", "small", UiKit.TEXT)
			var sample := _score % 3
			_canvas.draw_circle(Vector2(240, 125), 46, UiKit.PANEL)
			if sample == 0:
				_canvas.draw_colored_polygon(PackedVector2Array([Vector2(220,140),Vector2(232,95),Vector2(262,138),Vector2(240,130)]), UiKit.TEXT_DIM)
			elif sample == 1:
				for i in 7:
					_canvas.draw_circle(Vector2(220 + i * 6, 115 + i % 3 * 9), 5, UiKit.AMBER_DIM)
			else:
				_canvas.draw_line(Vector2(218,140),Vector2(260,105),UiKit.GREEN,5)
			var labels := ["Sharp lunar grains", "Soil grains", "Organic plant matter"]
			for i in 3:
				UiKit.draw_text(_canvas, Vector2(18 + i * 155, 195), ("> " if i == _choice else "") + labels[i], "small", UiKit.AMBER if i == _choice else UiKit.TEXT)
		&"harvest":
			UiKit.draw_text(_canvas, Vector2(20, 52), "Walk to the large ripe leaves. Press E to harvest.", "small", UiKit.TEXT)
			for i in 3:
				_canvas.draw_rect(Rect2(TARGETS[i] - Vector2(22,12),Vector2(44,26)),UiKit.AMBER_DIM)
				if i not in _collected:
					for leaf in 4:
						var offset := Vector2.RIGHT.rotated(float(leaf) * PI / 2.0) * 6.0
						_canvas.draw_circle(TARGETS[i] + offset, 5, UiKit.GREEN)
				_canvas.draw_line(TARGETS[i] + Vector2(0,7), TARGETS[i] - Vector2(0,7), UiKit.TEAL, 1)
			_canvas.draw_texture_rect(_astronaut, Rect2(_position.round() - Vector2(16,16), Vector2(32,32)), false)
	UiKit.draw_text(_canvas, Vector2(20, 238), _feedback, "small", UiKit.TEXT)
	UiKit.draw_text(_canvas, Vector2(20, 258), "Esc: leave and retry", "small", UiKit.TEXT_DIM)
