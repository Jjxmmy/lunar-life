extends "res://scripts/minigames/hands_on_lesson.gd"
const PARTS := ["Cooling garment", "Pressure suit", "Gloves", "Helmet", "Air and safety check"]
const FACTS := ["Water tubes carry extra heat away.", "The suit holds pressure around your body.", "Gloves protect your hands while you work.", "The helmet helps keep breathable air inside.", "Check air, seals and cooling with your crew."]
const BOLTS := [Vector2(160,110),Vector2(345,170),Vector2(275,115)]
var _choice := 0
var _position := Vector2(105,185)
var _velocity := Vector2.ZERO
var _feedback := ""
var _finished := false
var _astronaut: Texture2D = preload("res://assets/art/characters/astronaut/astronaut_front_idle.png")
func _process(delta: float) -> void:
	_time += delta
	if _result:
		if autopilot:
			_finish_lesson()
	elif kind == &"pool":
		var direction := Input.get_vector(&"move_left",&"move_right",&"move_up",&"move_down")
		if autopilot:
			var desired: Vector2 = (BOLTS[_score] - _position).limit_length(32.0)
			direction = ((desired - _velocity) / 25.0).limit_length(1.0)
		_velocity = (_velocity + direction * 100.0 * delta) * exp(-1.5 * delta)
		_position = (_position + _velocity * delta).clamp(Vector2(65,90),Vector2(415,205))
		if autopilot and _position.distance_to(BOLTS[_score]) < 16 and _velocity.length() < 24:
			_act()
	elif autopilot and fmod(_time,0.8) < delta:
		_choice = _step
		_act()
	_canvas.queue_redraw()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
	elif event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"move_left"):
		_choice = posmod(_choice - 1,PARTS.size())
	elif event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"move_right"):
		_choice = (_choice + 1) % PARTS.size()
	elif event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _result:
			_finish_lesson()
		else:
			_act()
func _act() -> void:
	if _result or _finished:
		return
	if kind == &"suit":
		if _choice != _step:
			_feedback = "Try " + PARTS[_step].to_lower() + " next."
			_mistakes += 1
			return
		_feedback = FACTS[_step]
		_step += 1
		_result = _step == PARTS.size()
	else:
		if _position.distance_to(BOLTS[_score]) > 20:
			_feedback = "Move close to the marked bolt."
			return
		if _velocity.length() > 24:
			_feedback = "Gently now! Let your drift slow before tightening."
			_mistakes += 1
			return
		_score += 1
		_feedback = "Bolt tightened. Gentle movements help you work."
		_result = _score == BOLTS.size()
	Sfx.play(&"confirm")
func _finish_lesson() -> void:
	if not _result or _finished:
		return
	_finished = true
	finished.emit()
	queue_free()
func _draw_activity() -> void:
	var c := _canvas
	var suit := kind == &"suit"
	LessonArt.frame(c, _time, "SUIT UP!" if suit else "FLOATY FIX - TRAINING POOL",
		"Why: a spacesuit is a tiny spaceship that keeps you alive." if suit else "Why: astronauts practise spacewalk jobs in a giant pool.",
		UiKit.TEAL)
	if _result:
		var learned := "A suit gives you air, pressure, cooling and protection. Each layer has a job." if suit \
			else "Floating in water feels a bit like space. Move gently so you can stop and work."
		LessonArt.result(c, _time, LessonArt.stars_for(_mistakes), learned)
		LessonArt.footer(c, "", "Simplified training, not a real NASA procedure.")
		return
	if suit:
		LessonArt.instruction(c, "Left/Right: pick the next part.  E: put it on.")
		LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _step, PARTS.size(), UiKit.GREEN)
		# Suit stand with a soft spotlight.
		c.draw_circle(Vector2(240, 150), 54, Color(UiKit.TEAL, 0.06))
		c.draw_rect(Rect2(214, 192, 52, 4), UiKit.LINE)
		_draw_suit(Vector2(240, 190), _step)
		# Equipment rack: one chip per part, done ones ticked.
		for i in PARTS.size():
			var r := Rect2(34 + i * 84, 196, 78, 15)
			if i < _step:
				c.draw_rect(r, Color(UiKit.GREEN, 0.14))
				c.draw_rect(r, UiKit.GREEN, false, 1.0)
				UiKit.draw_text(c, r.position + Vector2(4, 11), "+ " + _short(PARTS[i]), "small", UiKit.GREEN)
			else:
				LessonArt.chip(c, r, _short(PARTS[i]), i == _choice, _time)
	else:
		LessonArt.instruction(c, "WASD: swim gently.  Stop at the glowing bolt.  E: tighten.")
		LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _score, BOLTS.size(), UiKit.GREEN)
		var pool := Rect2(LessonArt.STAGE.position + Vector2(1, 1), LessonArt.STAGE.size - Vector2(2, 2))
		for band in 6:
			c.draw_rect(Rect2(pool.position.x, pool.position.y + band * pool.size.y / 6.0, pool.size.x, pool.size.y / 6.0 + 1), Color("1a5c86").lerp(Color("0b2a4a"), band / 5.0))
		for ray in 5:
			var x := 70.0 + ray * 85.0 + sin(_time * 0.6 + ray) * 8.0
			c.draw_colored_polygon(PackedVector2Array([Vector2(x, pool.position.y), Vector2(x + 14, pool.position.y), Vector2(x + 40, pool.end.y), Vector2(x + 22, pool.end.y)]), Color(1, 1, 1, 0.04))
		# Station mock-up: a truss with three bolt plates.
		c.draw_rect(Rect2(120, 104, 290, 8), Color("8a93b0"))
		c.draw_rect(Rect2(120, 104, 290, 2), Color("c9cfe0"))
		for k in 8:
			c.draw_line(Vector2(130 + k * 36, 112), Vector2(148 + k * 36, 104), Color("5b6584"), 1.0)
		c.draw_rect(Rect2(150, 112, 6, 90), Color("8a93b0"))
		c.draw_rect(Rect2(340, 112, 6, 90), Color("8a93b0"))
		for i in BOLTS.size():
			var b: Vector2 = BOLTS[i]
			c.draw_rect(Rect2(b - Vector2(10, 10), Vector2(20, 20)), Color("3a4466"))
			var col := UiKit.GREEN if i < _score else (UiKit.AMBER if i == _score else Color("8a93b0"))
			var hexp := PackedVector2Array()
			for k in 6:
				hexp.append(b + Vector2.RIGHT.rotated(k * PI / 3.0 + (_time * 2.0 if i < _score else 0.0)) * 6.0)
			c.draw_colored_polygon(hexp, col)
			UiKit.draw_text(c, b + Vector2(-2, 4), str(i + 1), "small", UiKit.INK)
			if i == _score:
				c.draw_arc(b, 16.0 + sin(_time * 4.0) * 2.0, 0, TAU, 24, UiKit.AMBER, 1.0)
		for i in 14:
			var bx := 40.0 + i * 30.0
			c.draw_circle(Vector2(bx, pool.end.y - fmod(_time * 14.0 + i * 17.0, pool.size.y)), 1.5 + (i % 2), Color(1, 1, 1, 0.35))
		# Tether from the pool edge, then the diver.
		c.draw_line(Vector2(pool.position.x + 4, pool.end.y - 6), _position + Vector2(0, -4), Color(UiKit.AMBER, 0.6), 1.0)
		c.draw_texture_rect(_astronaut, Rect2(_position.round() - Vector2(16, 16), Vector2(32, 32)), false)
		# Drift meter: words + bar.
		var speed := clampf(_velocity.length() / 48.0, 0.0, 1.0)
		var calm := _velocity.length() <= 24.0
		c.draw_rect(Rect2(pool.end.x - 110, pool.end.y - 14, 100, 6), Color(0, 0, 0, 0.5))
		c.draw_rect(Rect2(pool.end.x - 110, pool.end.y - 14, 100 * speed, 6), UiKit.GREEN if calm else UiKit.RED)
		UiKit.draw_text(c, Vector2(pool.end.x - 110, pool.end.y - 18), "Drift: " + ("gentle" if calm else "too fast!"), "small", UiKit.TEXT)
	LessonArt.footer(c, _feedback, "Simplified training, not a real NASA procedure." if suit else "Water copies some parts of working in space.")


func _short(part: String) -> String:
	return {"Cooling garment": "Cooling", "Pressure suit": "Suit", "Gloves": "Gloves", "Helmet": "Helmet", "Air and safety check": "Air check"}.get(part, part)


## The astronaut on the stand, wearing `layers` of the five parts.
func _draw_suit(feet: Vector2, layers: int) -> void:
	var c := _canvas
	var skin := Color("c98a5a")
	var under := Color("3a4a7a")
	var x := feet.x
	var y := feet.y
	# Body base.
	c.draw_rect(Rect2(x - 12, y - 52, 24, 30), under)
	c.draw_rect(Rect2(x - 11, y - 22, 9, 22), under)
	c.draw_rect(Rect2(x + 2, y - 22, 9, 22), under)
	c.draw_rect(Rect2(x - 18, y - 50, 6, 22), under)
	c.draw_rect(Rect2(x + 12, y - 50, 6, 22), under)
	c.draw_circle(Vector2(x, y - 62), 9, skin)
	c.draw_rect(Rect2(x - 3, y - 64, 2, 2), UiKit.INK)
	c.draw_rect(Rect2(x + 2, y - 64, 2, 2), UiKit.INK)
	if layers >= 1:   # cooling garment: blue with water tubes
		c.draw_rect(Rect2(x - 12, y - 52, 24, 30), Color("4f7dff"))
		for k in 4:
			c.draw_line(Vector2(x - 9 + k * 6, y - 50), Vector2(x - 9 + k * 6, y - 24), Color("a8c4ff"), 1.0)
	if layers >= 2:   # pressure suit: white, orange stripes, bulky
		var w := Color("eef1f8")
		c.draw_rect(Rect2(x - 15, y - 54, 30, 34), w)
		c.draw_rect(Rect2(x - 13, y - 22, 12, 22), w)
		c.draw_rect(Rect2(x + 1, y - 22, 12, 22), w)
		c.draw_rect(Rect2(x - 22, y - 52, 8, 24), w)
		c.draw_rect(Rect2(x + 14, y - 52, 8, 24), w)
		c.draw_rect(Rect2(x - 15, y - 34, 30, 3), Color("e37a40"))
		c.draw_rect(Rect2(x - 6, y - 50, 12, 8), Color("9aa3bd"))   # chest controls
		c.draw_rect(Rect2(x - 4, y - 48, 2, 2), UiKit.GREEN)
		c.draw_rect(Rect2(x + 1, y - 48, 2, 2), UiKit.AMBER)
	if layers >= 3:   # gloves
		c.draw_rect(Rect2(x - 23, y - 30, 10, 8), Color("9aa3bd"))
		c.draw_rect(Rect2(x + 13, y - 30, 10, 8), Color("9aa3bd"))
	if layers >= 4:   # helmet with visor and shine
		c.draw_circle(Vector2(x, y - 62), 14, Color("eef1f8"))
		c.draw_circle(Vector2(x, y - 61), 10, Color("2f5f8a"))
		c.draw_rect(Rect2(x - 6, y - 67, 4, 3), Color(1, 1, 1, 0.7))
	if layers >= 5:   # air check passed
		c.draw_circle(Vector2(x + 26, y - 74), 7, UiKit.GREEN)
		c.draw_line(Vector2(x + 23, y - 74), Vector2(x + 25, y - 71), UiKit.INK, 2.0)
		c.draw_line(Vector2(x + 25, y - 71), Vector2(x + 30, y - 78), UiKit.INK, 2.0)
