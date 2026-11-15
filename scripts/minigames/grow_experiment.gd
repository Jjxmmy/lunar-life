class_name GrowExperiment
extends CanvasLayer
## Light-recipe experiment (Day 3): three trays of the same seeds under three LED recipes.
## Thirty days of growth play out in about ten seconds, then the measured heights are shown.
## The growth numbers are simplified; the idea (plants use red and blue light most and
## reflect green) is the real one behind NASA's Veggie unit.

signal finished

const DAYS := 30
const DURATION := 9.0
## name, LED colours, relative growth rate (simplified)
const TRAYS: Array = [
	["Green only", [Color("4fd36a")], 0.32],
	["Red + blue", [Color("ff4f6a"), Color("4f7dff")], 1.0],
	["Red + blue + green", [Color("ff4f6a"), Color("4f7dff"), Color("4fd36a")], 0.96],
]

var _t: float = 0.0
var _done: bool = false
var _canvas: Control


static func open(parent: Node) -> GrowExperiment:
	var panel := GrowExperiment.new()
	parent.add_child(panel)
	return panel


func _ready() -> void:
	layer = 40
	MissionDirector.push_ui()
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_canvas = Control.new()
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_trays)
	add_child(_canvas)


func _exit_tree() -> void:
	MissionDirector.pop_ui()


func _process(delta: float) -> void:
	_t = minf(DURATION, _t + delta)
	_canvas.queue_redraw()


func _input(event: InputEvent) -> void:
	if _done:
		return
	if (event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")) and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _t < DURATION:
			_t = DURATION   # skip ahead to the result
		else:
			_done = true
			Sfx.play(&"confirm")
			finished.emit()
			queue_free()


func _draw_trays() -> void:
	var c := _canvas
	var frame := Rect2(80, 40, 320, 190)
	c.draw_rect(frame, UiKit.PANEL)
	c.draw_rect(frame, UiKit.TEAL, false, 1.0)
	var progress := _t / DURATION
	var day := maxi(1, int(roundf(progress * DAYS)))
	UiKit.draw_text(c, frame.position + Vector2(8, 14), "LIGHT-RECIPE EXPERIMENT", "title", UiKit.AMBER)
	UiKit.draw_text(c, frame.position + Vector2(8, 27), "Same seeds, same water. Only the light changes.   Day %d of %d" % [day, DAYS], "small", UiKit.TEXT)
	for i in TRAYS.size():
		var tray: Array = TRAYS[i]
		var x := frame.position.x + 22 + i * 100
		var floor_y := frame.end.y - 54
		# LED bar above the tray.
		var leds: Array = tray[1]
		for k in 8:
			c.draw_rect(Rect2(x + k * 9, frame.position.y + 38, 6, 3), leds[k % leds.size()])
		c.draw_rect(Rect2(x - 2, frame.position.y + 41, 76, floor_y - frame.position.y - 41), Color((leds[0] as Color), 0.07))
		# Plants: height grows with the recipe's rate.
		var height := roundf(progress * float(tray[2]) * 64.0)
		for k in 5:
			var px := x + 4 + k * 15
			var h := maxf(1.0, height - (k % 2) * 4.0)
			c.draw_rect(Rect2(px + 3, floor_y - h, 2, h), Color("2f8a3c"))
			if h > 6:
				c.draw_rect(Rect2(px, floor_y - h, 8, 3), Color("b0324a") if i > 0 else Color("6f9e57"))
				c.draw_rect(Rect2(px + 1, floor_y - h * 0.6, 6, 2), Color("b0324a") if i > 0 else Color("6f9e57"))
		c.draw_rect(Rect2(x - 2, floor_y, 76, 6), Color("6b5a44"))
		UiKit.draw_text(c, Vector2(x - 2, floor_y + 18), str(tray[0]), "small", UiKit.TEXT)
		if _t >= DURATION:
			UiKit.draw_text(c, Vector2(x - 2, floor_y + 30), "Height: %d" % int(height), "small", UiKit.AMBER)
	var hint := "E: skip to day %d" % DAYS if _t < DURATION else "E: log the results"
	UiKit.draw_text(c, Vector2(frame.position.x + 8, frame.end.y - 6), hint, "small", UiKit.TEXT_DIM)
