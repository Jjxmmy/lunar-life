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
	var c := _canvas
	var plant := kind == &"plant"
	LessonArt.frame(c, _time, "SPACE GARDEN" if plant else "BONE BUILDER",
		"Why: no soil up here - roots need pillows, water and light." if plant else "Why: without gravity's push, bones and muscles get weaker.",
		UiKit.GREEN if plant else UiKit.TEAL)
	if _result:
		var learned := "Seeds grow in pillows. A wick brings water from a tank. Red and blue lights feed the plants." if plant \
			else "Astronauts exercise about 2 hours a day to keep bones and muscles strong."
		LessonArt.result(c, _time, LessonArt.stars_for(_mistakes), learned)
		LessonArt.footer(c, "", "Based on NASA's Veggie garden. Simplified." if plant else "Based on space station exercise. Simplified.")
		return
	if plant:
		_draw_garden(c)
	else:
		_draw_bike(c)


func _draw_garden(c: Control) -> void:
	var steps := ["E: tuck a seed into each pillow.", "HOLD E to fill the tank. Let go in the green zone.", "E: switch on the red + blue grow lights."]
	LessonArt.instruction(c, steps[mini(_step, 2)])
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _step, 3, UiKit.GREEN)
	# Water tank with the target zone.
	var tank := Rect2(64, 92, 40, 104)
	c.draw_rect(tank.grow(2), Color("5b6584"))
	c.draw_rect(tank, Color("0a1630"))
	var level := tank.size.y * _water / 100.0
	c.draw_rect(Rect2(tank.position.x, tank.end.y - level, tank.size.x, level), Color("3a8fd8"))
	c.draw_rect(Rect2(tank.position.x, tank.end.y - level, tank.size.x, 2), Color("a8d8ff"))
	var zone := Rect2(tank.position.x - 4, tank.end.y - tank.size.y * 0.7, tank.size.x + 8, tank.size.y * 0.3)
	c.draw_rect(zone, UiKit.GREEN, false, 1.0)
	UiKit.draw_text(c, Vector2(tank.end.x + 6, zone.position.y + 10), "just right", "small", UiKit.GREEN)
	UiKit.draw_text(c, Vector2(tank.position.x - 2, tank.end.y + 12), "WATER TANK", "small", UiKit.TEXT_DIM)
	# Grow tray with three pillows and wicks.
	var tray := Rect2(180, 168, 220, 16)
	c.draw_rect(tray, Color("5b6584"))
	c.draw_rect(Rect2(tray.position, Vector2(tray.size.x, 2)), Color("8a93b0"))
	var wet := _water > 0.0 and _step >= 1
	c.draw_line(Vector2(tank.end.x, tank.end.y - 10), Vector2(tray.position.x, tray.position.y + 8), Color("3a8fd8") if wet else UiKit.LINE, 2.0)
	for k in 3:
		var px := tray.position.x + 30 + k * 72
		var pillow := Rect2(px - 22, tray.position.y - 14, 44, 16)
		c.draw_rect(pillow, Color("c9a87a"))
		c.draw_rect(Rect2(pillow.position, Vector2(pillow.size.x, 2)), Color("e3c99e"))
		c.draw_rect(Rect2(pillow.position.x + 4, pillow.end.y - 3, pillow.size.x - 8, 2), Color("3a8fd8") if wet else Color("8a7258"))
		if _step >= 1:   # sprout, taller once the lights are on
			var h := 8.0 if _step == 1 else 8.0 + minf(_time * 6.0, 14.0)
			if _step >= 3:
				h = 22.0
			c.draw_rect(Rect2(px - 1, pillow.position.y - h, 2, h), Color("2f8a3c"))
			c.draw_rect(Rect2(px - 7, pillow.position.y - h, 6, 4), Color("b0324a"))
			c.draw_rect(Rect2(px + 1, pillow.position.y - h + 3, 6, 4), Color("4fae5a"))
		elif int(_time * 3.0) % 2 == 0:
			c.draw_rect(Rect2(px - 2, pillow.position.y - 4, 4, 4), UiKit.AMBER)
	# LED bar.
	var lit := _step >= 2
	c.draw_rect(Rect2(170, 92, 240, 8), Color("2a2f45"))
	for k in 20:
		var on := lit and (int(_time * 6.0) + k) % 7 != 0
		c.draw_rect(Rect2(174 + k * 12, 94, 8, 4), (Color("ff4f6a") if k % 2 == 0 else Color("4f7dff")) if on else UiKit.LINE)
	if lit:
		c.draw_colored_polygon(PackedVector2Array([Vector2(170, 100), Vector2(410, 100), Vector2(400, 168), Vector2(180, 168)]), Color(0.9, 0.3, 0.6, 0.08))
	UiKit.draw_text(c, Vector2(176, 88), "GROW LIGHTS " + ("ON" if lit else "OFF"), "small", UiKit.TEXT_DIM)
	LessonArt.footer(c, "Tank -> wick -> pillow -> roots. Too much water drowns roots!" if _step == 1 else "", "Based on NASA's Veggie garden. Simplified.")


func _draw_bike(c: Control) -> void:
	LessonArt.instruction(c, "Tap E when the pedal dot is inside the box.")
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _score, 8, UiKit.TEAL)
	# Bike + rider.
	var base := Vector2(150, 176)
	c.draw_rect(Rect2(base.x - 40, base.y + 10, 90, 5), Color("5b6584"))
	var wheel := base + Vector2(-20, 0)
	c.draw_arc(wheel, 14, 0, TAU, 24, Color("8a93b0"), 3.0)
	var crank := Vector2.RIGHT.rotated(_time * 4.0) * 10.0
	c.draw_line(wheel, wheel + crank, UiKit.AMBER, 2.0)
	c.draw_line(base + Vector2(18, -30), base + Vector2(18, 10), Color("8a93b0"), 3.0)
	c.draw_rect(Rect2(base.x + 10, base.y - 34, 18, 4), Color("2a2f45"))
	c.draw_rect(Rect2(base.x - 16, base.y - 16, 16, 4), Color("2a2f45"))
	var bob := absf(sin(_time * 4.0)) * 2.0
	c.draw_texture_rect(preload("res://assets/art/characters/astronaut/astronaut_right_idle.png"), Rect2(base + Vector2(-22, -44 - bob), Vector2(32, 32)), false)
	# Beat track.
	var track := Rect2(230, 120, 200, 10)
	c.draw_rect(track, Color(0, 0, 0, 0.5))
	var box := Rect2(track.position.x + track.size.x / 2.0 - 16, track.position.y - 8, 32, 26)
	c.draw_rect(box, Color(UiKit.GREEN, 0.15))
	c.draw_rect(box, UiKit.GREEN, false, 1.0)
	var dot := Vector2(track.position.x + track.size.x / 2.0 + sin(_time * 2.0) * (track.size.x / 2.0 - 6), track.position.y + 5)
	var inside := absf(sin(_time * 2.0)) < 0.3
	c.draw_circle(dot, 6, UiKit.GREEN if inside else UiKit.AMBER)
	# Bone strength meter: a bone icon filling up.
	var bone := Rect2(250, 160, 160, 12)
	c.draw_circle(bone.position + Vector2(0, 2), 5, Color("eef1f8"))
	c.draw_circle(bone.position + Vector2(0, 10), 5, Color("eef1f8"))
	c.draw_circle(Vector2(bone.end.x, bone.position.y + 2), 5, Color("eef1f8"))
	c.draw_circle(Vector2(bone.end.x, bone.position.y + 10), 5, Color("eef1f8"))
	c.draw_rect(bone, Color("3a4466"))
	c.draw_rect(Rect2(bone.position, Vector2(bone.size.x * _score / 8.0, bone.size.y)), Color("eef1f8"))
	UiKit.draw_text(c, Vector2(250, 190), "Strong steps: %d / 8" % _score, "small", UiKit.TEXT)
	LessonArt.footer(c, "Nice rhythm! Keep going." if _score > 0 else "", "Real bone changes take weeks, not seconds.")
