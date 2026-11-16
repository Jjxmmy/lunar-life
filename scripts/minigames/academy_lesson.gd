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
	_canvas.draw_rect(Rect2(0,0,480,270),UiKit.INK)
	UiKit.draw_text(_canvas,Vector2(20,25),"SUIT UP!" if kind == &"suit" else "FLOATY FIX - TRAINING POOL","title",UiKit.AMBER)
	if _result:
		UiKit.draw_text(_canvas,Vector2(20,80),"TRAINING COMPLETE - %d STARS" % maxi(1,3 - _mistakes / 3),"title",UiKit.GREEN)
		var fact := "A suit provides air, pressure, cooling and protection." if kind == &"suit" else "Gentle movements help you stop and work carefully."
		UiKit.draw_text(_canvas,Vector2(20,115),"You learned: " + fact,"small",UiKit.TEXT)
		UiKit.draw_text(_canvas,Vector2(20,150),"E: earn badge    Esc: leave without completion","small",UiKit.TEXT)
		return
	if kind == &"suit":
		UiKit.draw_text(_canvas,Vector2(20,48),"Why: your body needs air, pressure and cooling.","small",UiKit.TEXT)
		UiKit.draw_text(_canvas,Vector2(20,67),"Left/right: choose equipment. E: equip or check it.","small",UiKit.TEXT)
		_canvas.draw_rect(Rect2(220,120,40,42),UiKit.TEAL if _step >= 1 else UiKit.PANEL)
		_canvas.draw_rect(Rect2(220,160,15,26),UiKit.PANEL)
		_canvas.draw_rect(Rect2(245,160,15,26),UiKit.PANEL)
		if _step >= 1:
			for tube in 4:
				_canvas.draw_line(Vector2(225+tube*8,124),Vector2(225+tube*8,156),UiKit.TEXT_DIM,1)
		_canvas.draw_circle(Vector2(240,105),14,UiKit.AMBER_DIM)
		if _step >= 2:
			_canvas.draw_rect(Rect2(216,118,48,46),UiKit.TEXT)
			_canvas.draw_rect(Rect2(203,122,13,28),UiKit.TEXT)
			_canvas.draw_rect(Rect2(264,122,13,28),UiKit.TEXT)
			_canvas.draw_rect(Rect2(220,160,15,26),UiKit.TEXT)
			_canvas.draw_rect(Rect2(245,160,15,26),UiKit.TEXT)
		if _step >= 3:
			_canvas.draw_rect(Rect2(199,145,12,14),UiKit.TEXT)
			_canvas.draw_rect(Rect2(269,145,12,14),UiKit.TEXT)
		if _step >= 4:
			_canvas.draw_arc(Vector2(240,112),23,0,TAU,24,UiKit.TEAL,2)
		UiKit.draw_text(_canvas,Vector2(20,207),"< " + PARTS[_choice] + " >    %d / 5 ready" % _step,"title",UiKit.AMBER)
	else:
		UiKit.draw_text(_canvas,Vector2(20,48),"Why: astronauts practise spacewalk jobs underwater.","small",UiKit.TEXT)
		UiKit.draw_text(_canvas,Vector2(20,67),"Move gently. Stop near each numbered bolt. E: tighten.","small",UiKit.TEXT)
		_canvas.draw_rect(Rect2(50,82,380,130),Color("123f60"))
		for i in 12:
			_canvas.draw_circle(Vector2(65+i*30,205-fmod(_time*12+i*13,115)),2,UiKit.TEAL_DIM)
		for i in BOLTS.size():
			_canvas.draw_rect(Rect2(BOLTS[i]-Vector2(7,7),Vector2(14,14)),UiKit.GREEN if i < _score else UiKit.AMBER_DIM)
			UiKit.draw_text(_canvas,BOLTS[i]+Vector2(-2,3),str(i+1),"small",UiKit.TEXT)
			if i == _score:
				_canvas.draw_arc(BOLTS[i],20,0,TAU,24,UiKit.AMBER,1)
		_canvas.draw_texture_rect(_astronaut,Rect2(_position.round()-Vector2(16,16),Vector2(32,32)),false)
	UiKit.draw_text(_canvas,Vector2(20,232),_feedback,"small",UiKit.TEXT)
	var caveat := "Simplified training, not a real suit procedure." if kind == &"suit" else "Buoyancy simulates some parts of working in space."
	UiKit.draw_text(_canvas,Vector2(20,249),caveat,"small",UiKit.TEXT_DIM)
	UiKit.draw_text(_canvas,Vector2(20,264),"Esc: leave and try again","small",UiKit.TEXT_DIM)
