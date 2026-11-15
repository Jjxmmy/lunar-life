class_name ArmDrill
extends CanvasLayer
## Robotic-arm capture drill (Day 1). A tiny version of Canadarm2 training: steer the
## grapple with WASD / arrows, line it up with the drifting cargo's grapple pin and press E
## to capture. Three captures finish the drill. There is no fail state and no timer: the
## lesson is "move slowly and match the drift". Esc leaves without finishing.

signal finished
signal closed

const CAPTURES_NEEDED := 3
const SPEED := 46.0
const CATCH_RADIUS := 6.0
const AREA := Rect2(110, 62, 260, 150)

## Test hook: the playtest sets this to steer and grab by itself.
var autopilot: bool = false

var _tip := Vector2(170, 170)
var _cargo_home := Vector2(300, 110)
var _cargo := Vector2.ZERO
var _time: float = 0.0
var _captures: int = 0
var _flash: float = 0.0
var _miss: float = 0.0
var _done: bool = false
var _canvas: Control


static func open(parent: Node) -> ArmDrill:
	var drill := ArmDrill.new()
	parent.add_child(drill)
	return drill


func _ready() -> void:
	layer = 40
	MissionDirector.push_ui()
	Sfx.play(&"open")
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_canvas = Control.new()
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_drill)
	add_child(_canvas)
	_new_target()


func _exit_tree() -> void:
	MissionDirector.pop_ui()


func _new_target() -> void:
	_cargo_home = Vector2(randf_range(AREA.position.x + 120, AREA.end.x - 30), randf_range(AREA.position.y + 25, AREA.end.y - 40))


func _process(delta: float) -> void:
	if _done:
		return
	_time += delta
	_flash = maxf(0.0, _flash - delta)
	_miss = maxf(0.0, _miss - delta)
	# The cargo ship drifts slowly, like a spacecraft holding station next to the arm.
	_cargo = _cargo_home + Vector2(sin(_time * 0.7) * 14.0, cos(_time * 0.5) * 8.0)
	var dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if autopilot:
		var to := _pin() - _tip
		dir = to.normalized() if to.length() > 1.5 else Vector2.ZERO
		if to.length() <= CATCH_RADIUS * 0.6:
			_grab()
	_tip = (_tip + dir * SPEED * delta).clamp(AREA.position + Vector2(8, 8), AREA.end - Vector2(8, 8))
	_canvas.queue_redraw()


func _pin() -> Vector2:
	return _cargo + Vector2(-12, 0)


func _input(event: InputEvent) -> void:
	if _done:
		return
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close(false)
	elif event.is_action_pressed(&"interact") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _captures >= CAPTURES_NEEDED:
			_close(true)
		else:
			_grab()


func _grab() -> void:
	if _captures >= CAPTURES_NEEDED:
		return
	if _tip.distance_to(_pin()) <= CATCH_RADIUS:
		_captures += 1
		_flash = 0.6
		Sfx.play(&"confirm")
		if _captures < CAPTURES_NEEDED:
			_new_target()
		elif autopilot:
			_close.call_deferred(true)
	else:
		_miss = 0.5
		Sfx.play(&"cancel")


func _close(complete: bool) -> void:
	if _done:
		return
	_done = true
	if complete:
		finished.emit()
	else:
		closed.emit()
	queue_free()


func _draw_drill() -> void:
	var c := _canvas
	var frame := AREA.grow_individual(14, 38, 14, 34)
	c.draw_rect(frame, UiKit.PANEL)
	c.draw_rect(frame, UiKit.TEAL, false, 1.0)
	UiKit.draw_text(c, frame.position + Vector2(8, 14), "ROBOTIC ARM DRILL", "title", UiKit.AMBER)
	UiKit.draw_text(c, frame.position + Vector2(8, 27), "Line up the grapple with the cargo's pin, then press E.", "small", UiKit.TEXT)
	c.draw_rect(AREA, Color("0a0c1e"))
	# Stars drift past the workspace.
	for i in 24:
		var sx := AREA.position.x + fmod(i * 37.0 + _time * 4.0, AREA.size.x)
		var sy := AREA.position.y + fmod(i * 53.0, AREA.size.y)
		c.draw_rect(Rect2(sx, sy, 1, 1), Color(1, 1, 1, 0.35))
	# Cargo ship with its grapple pin.
	var body := Rect2(_cargo - Vector2(10, 8), Vector2(26, 16))
	c.draw_rect(body, Color("c9cfe0"))
	c.draw_rect(body, Color("6c7390"), false, 1.0)
	c.draw_rect(Rect2(_cargo + Vector2(16, -12), Vector2(6, 24)), Color("3a6fd0"))
	var pin := _pin()
	c.draw_rect(Rect2(pin - Vector2(2, 2), Vector2(4, 4)), UiKit.AMBER)
	c.draw_arc(pin, CATCH_RADIUS, 0.0, TAU, 16, Color(UiKit.AMBER, 0.45), 1.0)
	# Arm: base on the station, elbow, then the grapple at the tip.
	var base := Vector2(AREA.position.x + 4, AREA.end.y - 6)
	var mid := (base + _tip) * 0.5 + Vector2(0, -28)
	c.draw_line(base, mid, Color("e8ecf5"), 4.0)
	c.draw_line(mid, _tip, Color("e8ecf5"), 3.0)
	c.draw_rect(Rect2(mid - Vector2(3, 3), Vector2(6, 6)), Color("8a93b0"))
	var near := _tip.distance_to(pin) <= CATCH_RADIUS
	c.draw_rect(Rect2(_tip - Vector2(3, 3), Vector2(6, 6)), UiKit.GREEN if near else UiKit.TEAL)
	# Status line: captures as words AND pips (never colour alone).
	var status := "Captured %d of %d" % [_captures, CAPTURES_NEEDED]
	if _captures >= CAPTURES_NEEDED:
		status = "All cargo captured!  Press E to finish."
	elif near:
		status += "   IN RANGE - press E"
	elif _miss > 0.0:
		status += "   Missed - get closer"
	UiKit.draw_text(c, Vector2(AREA.position.x, AREA.end.y + 14), status, "small", UiKit.GREEN if _flash > 0.0 else UiKit.TEXT)
	UiKit.draw_text(c, Vector2(AREA.position.x, AREA.end.y + 26), "Move: WASD / arrows     Esc: leave", "small", UiKit.TEXT_DIM)
