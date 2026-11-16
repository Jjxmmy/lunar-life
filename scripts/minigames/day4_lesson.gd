extends "res://scripts/minigames/hands_on_lesson.gd"
## Day 4 hands-on lessons: Storm Spotter (kind &"weather") and Message to Earth (kind &"message").
## Uses the hands_on_lesson lifecycle: leaving with Esc never completes the task.

const EVENT_TIME := 1.7
## name, is it a warning sign, what the player is told afterwards
const EVENTS := [
	["FLARE", true, "A flare is a bright flash. Big ones can come with particle storms."],
	["SUNSPOT", false, "Sunspots are darker, cooler patches. Just a sunspot is no alarm."],
	["CME", true, "A CME is a huge cloud of gas thrown off the Sun. Fast ones can push particles our way."],
	["QUIET", false, "Quiet Sun. Nothing to report."],
]
const MOON_DELAY := 1.3            # real one-way light time to the Moon, about 1.3 s
const MARS_SHOWN := 6.0            # Mars is 3-22 minutes each way; sped up for the game

var _finished := false
var _feedback := ""
var _event := 0
var _event_t := 0.0
var _answered := false
var _order: Array[int] = [0, 1, 3, 2, 1, 0, 3, 2, 0, 1, 2, 3, 0]
var _signal := 0.0                 # message travel progress, seconds
var _choice := 0


func _process(delta: float) -> void:
	_time += delta
	if _result:
		if autopilot:
			_finish_lesson()
		_canvas.queue_redraw()
		return
	if kind == &"weather":
		_event_t += delta
		if autopilot and not _answered and EVENTS[_current()][1] and _event_t > 0.3:
			_act()
		if _event_t >= EVENT_TIME:
			if not _answered and EVENTS[_current()][1]:
				_feedback = "Missed a " + str(EVENTS[_current()][0]) + "! Watch for flashes and clouds."
			_event_t = 0.0
			_answered = false
			_event += 1
	else:
		if _step == 1 or _step == 3:
			_signal += delta
			var trip := MOON_DELAY * 2.0 if _step == 1 else MARS_SHOWN * 2.0
			if _signal >= trip:
				_step += 1
				_signal = 0.0
				Sfx.play(&"confirm")
				_feedback = "Reply received after %.1f s." % trip if _step == 2 else "The Mars reply finally arrived!"
		elif autopilot and fmod(_time, 0.5) < delta:
			_act()
	_canvas.queue_redraw()


func _current() -> int:
	return _order[_event % _order.size()]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
	elif kind == &"message" and _step == 4 and (event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"move_left") or event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"move_right")):
		_choice = 1 - _choice
	elif event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _result:
			_finish_lesson()
		else:
			_act()


func _act() -> void:
	if _result or _finished:
		return
	if kind == &"weather":
		if _answered:
			return
		_answered = true
		var ev: Array = EVENTS[_current()]
		if ev[1]:
			_score += 1
			_feedback = "Good catch! " + str(ev[2])
			Sfx.play(&"confirm")
		else:
			_mistakes += 1
			_feedback = "Not that one. " + str(ev[2])
			Sfx.play(&"cancel")
		_result = _score >= 5
	else:
		match _step:
			0, 2:
				_step += 1
				_signal = 0.0
				_feedback = "Signal sent..."
				Sfx.play(&"confirm")
			4:
				_feedback = "Smart! With a long delay, crews must solve urgent problems themselves." if _choice == 1 \
					else "Waiting is safe for small things, but on Mars help is 20+ minutes away. Urgent jobs can't wait."
				_result = true
				Sfx.play(&"confirm")


func _finish_lesson() -> void:
	if not _result or _finished:
		return
	_finished = true
	ResourceSim.science_progress += 2
	finished.emit()
	queue_free()


func _draw_activity() -> void:
	var c := _canvas
	var weather := kind == &"weather"
	LessonArt.frame(c, _time, "STORM SPOTTER" if weather else "MESSAGE TO EARTH",
		"Why: scientists watch the Sun all day to warn astronauts early." if weather else "Why: radio signals take time to cross space.",
		UiKit.AMBER if weather else UiKit.TEAL)
	if _result:
		var learned := "Flares and CMEs are warning signs. Watching the Sun gives astronauts time to get to shelter." if weather \
			else "A message to the Moon takes about 1.3 seconds each way. To Mars it takes 3 to 22 minutes, so crews must think for themselves."
		LessonArt.result(c, _time, LessonArt.stars_for(_mistakes), learned)
		LessonArt.footer(c, "", "Event types from NASA's DONKI. Real storm replayed: May 10, 2024." if weather else "Light-travel times from NASA. Mars sped up for the game.")
		return
	if weather:
		_draw_sun_cam(c)
	else:
		_draw_radio(c)
	LessonArt.footer(c, _feedback, "Simulated sun-cam. Event types from NASA's DONKI." if weather else "Moon delay is real time. Mars is sped up.")


func _draw_sun_cam(c: Control) -> void:
	LessonArt.instruction(c, "E: press ONLY for a FLARE or a CME. Ignore sunspots.")
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _score, 5, UiKit.AMBER)
	var sun := Vector2(200, 138)
	var ev: Array = EVENTS[_current()]
	var ev_name := str(ev[0])
	# Monitor frame.
	c.draw_rect(Rect2(110, 74, 180, 134), Color("05070f"))
	c.draw_rect(Rect2(110, 74, 180, 134), Color("5b6584"), false, 2.0)
	UiKit.draw_text(c, Vector2(116, 86), "SUN-CAM  (simulated)", "small", UiKit.TEXT_DIM)
	if int(_time * 2.0) % 2 == 0:
		c.draw_circle(Vector2(282, 82), 2, UiKit.RED)
	# Round, glowing sun.
	for ring in 4:
		c.draw_circle(sun, 42.0 + ring * 4.0, Color(1.0, 0.6, 0.15, 0.08))
	c.draw_circle(sun, 40, Color("ff9a2e"))
	c.draw_circle(sun, 32, Color("ffc04a"))
	c.draw_circle(sun + Vector2(-8, -8), 12, Color("ffe08a"))
	var k := clampf(_event_t / EVENT_TIME, 0.0, 1.0)
	match ev_name:
		"FLARE":
			var flash := sin(k * PI)
			c.draw_circle(sun + Vector2(18, -14), 6 + flash * 10, Color(1, 1, 0.85, 0.9 * flash))
			for r in 8:
				var d := Vector2.RIGHT.rotated(r * PI / 4.0)
				c.draw_line(sun + Vector2(18, -14) + d * 8, sun + Vector2(18, -14) + d * (14 + flash * 14), Color(1, 1, 0.8, flash), 1.0)
		"CME":
			var rad := 40.0 + k * 50.0
			c.draw_arc(sun, rad, -PI * 0.45, PI * 0.15, 24, Color(1.0, 0.75, 0.4, 1.0 - k), 3.0)
			c.draw_arc(sun, rad - 6, -PI * 0.4, PI * 0.1, 24, Color(1.0, 0.75, 0.4, 0.5 * (1.0 - k)), 2.0)
		"SUNSPOT":
			c.draw_circle(sun + Vector2(-12, 10), 5, Color("8a3a10"))
			c.draw_circle(sun + Vector2(-4, 14), 3, Color("8a3a10"))
	# Reveal what it was once answered (words, not just colour).
	if _answered:
		UiKit.draw_text(c, Vector2(116, 202), "That was: " + ev_name, "small", UiKit.GREEN if ev[1] else UiKit.AMBER)
	# Side panel: what to look for.
	var key := Rect2(310, 78, 136, 126)
	c.draw_rect(key, Color(0, 0, 0, 0.35))
	UiKit.draw_text(c, key.position + Vector2(8, 14), "WARNING SIGNS", "small", UiKit.AMBER)
	UiKit.draw_text(c, key.position + Vector2(8, 32), "* FLARE: bright flash", "small", UiKit.TEXT)
	UiKit.draw_text(c, key.position + Vector2(8, 46), "* CME: gas cloud puff", "small", UiKit.TEXT)
	UiKit.draw_text(c, key.position + Vector2(8, 70), "NOT AN ALARM", "small", UiKit.GREEN)
	UiKit.draw_text(c, key.position + Vector2(8, 88), "- dark sunspot", "small", UiKit.TEXT)
	UiKit.draw_text(c, key.position + Vector2(8, 102), "- quiet sun", "small", UiKit.TEXT)
	UiKit.draw_text(c, key.position + Vector2(8, 120), "Caught: %d / 5" % _score, "small", UiKit.TEXT)


func _draw_radio(c: Control) -> void:
	var steps := ["E: send a question to Earth.", "Signal travelling to Earth and back...", "E: now try Mars (far away).", "Signal crossing to Mars and back... (sped up!)", "A pipe leaks NOW. Left/Right: choose.  E: decide."]
	LessonArt.instruction(c, steps[mini(_step, 4)])
	LessonArt.pips(c, Vector2(LessonArt.STAGE.end.x - 6, LessonArt.STAGE.position.y + 8), _step, 5, UiKit.TEAL)
	var mars := _step >= 2
	var home := Vector2(70, 140)
	var far := Vector2(410, 140)
	# Moon (us) on the left, Earth or Mars on the right.
	c.draw_circle(home, 22, Color("c9cfe0"))
	c.draw_circle(home + Vector2(-6, -5), 5, Color("9aa3bd"))
	UiKit.draw_text(c, home + Vector2(-14, 36), "MOON", "small", UiKit.TEXT)
	if mars:
		c.draw_circle(far, 18, Color("c8553a"))
		c.draw_circle(far + Vector2(5, -4), 4, Color("a0402a"))
		UiKit.draw_text(c, far + Vector2(-14, 34), "MARS", "small", UiKit.TEXT)
	else:
		c.draw_circle(far, 22, Color("2f6fd0"))
		c.draw_rect(Rect2(far + Vector2(-8, -6), Vector2(10, 8)), Color("4fae5a"))
		UiKit.draw_text(c, far + Vector2(-16, 36), "EARTH", "small", UiKit.TEXT)
	# Path and the travelling signal dot.
	for x in range(int(home.x) + 26, int(far.x) - 22, 8):
		c.draw_rect(Rect2(x, home.y, 3, 1), UiKit.LINE)
	if _step == 1 or _step == 3:
		var one_way := MOON_DELAY if _step == 1 else MARS_SHOWN
		var going := _signal < one_way
		var f := (_signal / one_way) if going else (_signal - one_way) / one_way
		var p := home.lerp(far, f) if going else far.lerp(home, f)
		c.draw_circle(p, 4, UiKit.AMBER if going else UiKit.GREEN)
		c.draw_arc(p, 7 + fmod(_time * 10.0, 4.0), 0, TAU, 12, Color(UiKit.AMBER, 0.4), 1.0)
		UiKit.draw_text(c, Vector2(180, 118), ("question -> " if going else "<- reply") + "  %.1f s" % _signal, "small", UiKit.TEXT)
	var label := "Moon: about 1.3 s each way (real time)" if not mars else "Mars: 3 to 22 MINUTES each way"
	UiKit.draw_text(c, Vector2(150, 176), label, "small", UiKit.AMBER)
	if _step == 4:
		LessonArt.chip(c, Rect2(110, 190, 120, 16), "Wait for Earth", _choice == 0, _time)
		LessonArt.chip(c, Rect2(250, 190, 120, 16), "Fix it yourself", _choice == 1, _time)
