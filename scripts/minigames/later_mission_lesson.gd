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
	var c := _canvas
	var dust := kind == &"regolith"
	LessonArt.frame(c, _time, "DUST DETECTIVE" if dust else "FIRST HARVEST",
		"Why: moon dust is not soil, so plants need help to grow." if dust else "Why: fresh food keeps the crew healthy and happy.",
		UiKit.AMBER if dust else UiKit.GREEN)
	if _result:
		var learned := "Moon dust is sharp and has no plant food. In 2022, plants grown in Apollo moon dust survived but were stressed." if dust \
			else "Fresh leaves add vitamins and variety to space meals - and caring for plants cheers up the crew."
		LessonArt.result(c, _time, 3, learned)
		LessonArt.footer(c, "", "Illustration based on a NASA-funded 2022 study." if dust else "Based on NASA's Veggie harvests on the space station.")
		return
	if dust:
		_draw_microscope(c)
	else:
		_draw_beds(c)
	LessonArt.footer(c, _feedback, "Samples drawn for illustration." if dust else "Simplified harvest.")


func _draw_microscope(c: Control) -> void:
	LessonArt.instruction(c, "Look closely. Left/Right: pick a tray.  E: sort it.")
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _score, 6, UiKit.AMBER)
	var lens := Vector2(240, 120)
	c.draw_circle(lens, 46, Color("5b6584"))
	c.draw_circle(lens, 42, Color("101a30"))
	var sample := _score % 3
	if sample == 0:   # sharp, glassy lunar grains
		for k in 6:
			var o := Vector2(-24 + (k % 3) * 22, -12 + (k / 3) * 22)
			c.draw_colored_polygon(PackedVector2Array([lens + o + Vector2(-7, 6), lens + o + Vector2(-2, -9), lens + o + Vector2(8, 4), lens + o + Vector2(1, 2)]), Color("a7adbd"))
			c.draw_line(lens + o + Vector2(-2, -9), lens + o + Vector2(1, 2), Color("eef1f8"), 1.0)
	elif sample == 1:  # round, crumbly soil grains
		for k in 9:
			var o := Vector2(-22 + (k % 3) * 22, -20 + (k / 3) * 20)
			c.draw_circle(lens + o, 6, Color("8a6440"))
			c.draw_circle(lens + o + Vector2(-2, -2), 2, Color("b08a60"))
	else:              # organic matter: roots and leaf bits
		for k in 4:
			var a := lens + Vector2(-26 + k * 16, -18)
			c.draw_line(a, a + Vector2(6, 36), Color("6b4a2a"), 3.0)
			c.draw_rect(Rect2(a + Vector2(2, 8 + k * 4), Vector2(8, 5)), Color("4fae5a"))
	c.draw_arc(lens, 42, PI * 1.1, PI * 1.4, 8, Color(1, 1, 1, 0.3), 2.0)
	UiKit.draw_text(c, lens + Vector2(-26, 58), "SAMPLE %d" % (_score + 1), "small", UiKit.TEXT_DIM)
	var labels := ["Sharp moon grains", "Soil grains", "Plant bits"]
	for i in 3:
		LessonArt.chip(c, Rect2(40 + i * 136, 194, 128, 16), labels[i], i == _choice, _time)


func _draw_beds(c: Control) -> void:
	LessonArt.instruction(c, "WASD: walk to a ripe bed.  E: pick the leaves.")
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _score, 3, UiKit.GREEN)
	c.draw_rect(Rect2(LessonArt.STAGE.position + Vector2(1, 1), LessonArt.STAGE.size - Vector2(2, 2)), Color("1f2a3a"))
	for i in TARGETS.size():
		var t: Vector2 = TARGETS[i]
		var bed := Rect2(t - Vector2(26, 2), Vector2(52, 14))
		c.draw_rect(Rect2(bed.position.x, bed.position.y - 30, bed.size.x, 3), Color("ff4f6a") if (int(_time * 4.0) + i) % 2 == 0 else Color("4f7dff"))
		c.draw_rect(bed, Color("6b5a4e"))
		c.draw_rect(Rect2(bed.position, Vector2(bed.size.x, 2)), Color("8a7565"))
		if i in _collected:
			for k in 4:
				c.draw_rect(Rect2(bed.position.x + 6 + k * 12, bed.position.y - 3, 2, 3), Color("2f8a3c"))
			UiKit.draw_text(c, bed.position + Vector2(12, -10 - minf(_time, 1.0)), "+ picked", "small", UiKit.GREEN)
		else:
			for k in 4:
				var lx := bed.position.x + 7 + k * 12
				var sway := sin(_time * 2.0 + k) * 1.0
				c.draw_rect(Rect2(lx - 4 + sway, bed.position.y - 14, 8, 12), Color("b0324a"))
				c.draw_rect(Rect2(lx - 2 + sway, bed.position.y - 18, 5, 6), Color("4fae5a"))
			if _position.distance_to(t) < 22:
				c.draw_rect(bed.grow(3), UiKit.AMBER, false, 1.0)
	c.draw_texture_rect(_astronaut, Rect2(_position.round() - Vector2(16, 16), Vector2(32, 32)), false)
	# Basket counter.
	var basket := Rect2(LessonArt.STAGE.end.x - 70, LessonArt.STAGE.end.y - 26, 60, 20)
	c.draw_rect(basket, Color("8a6440"))
	for k in _score:
		c.draw_rect(Rect2(basket.position.x + 6 + k * 16, basket.position.y - 6, 12, 8), Color("b0324a"))
	UiKit.draw_text(c, basket.position + Vector2(6, 15), "%d / 3" % _score, "small", UiKit.TEXT)
