extends Control
## Small, skippable-by-nature story illustration used for graduation and first arrival.

enum Moment { GRADUATION, ARRIVAL }

var moment: Moment = Moment.GRADUATION
var _elapsed := 0.0
var _duration := 1.8


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if moment == Moment.ARRIVAL:
		_duration = 2.4
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.22)
	tween.tween_interval(_duration - 0.55)
	tween.tween_property(self, "modulate:a", 0.0, 0.33)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()


func _draw() -> void:
	if moment == Moment.ARRIVAL:
		_draw_arrival()
	else:
		_draw_graduation()


func _draw_arrival() -> void:
	var screen := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, screen), Color("080d20", 0.92))
	for i in 48:
		var x := float((i * 83 + 29) % 480)
		var y := float((i * 47 + 17) % 188)
		draw_rect(Rect2(Vector2(x, y), Vector2(1, 1)), Color(0.78, 0.89, 1.0, 0.55 + 0.4 * absf(sin(_elapsed * 2.0 + i))))
	var moon := Vector2(347, 102)
	draw_circle(moon, 57, Color("777c91"))
	draw_circle(moon + Vector2(-20, -15), 10, Color("696f85"))
	draw_circle(moon + Vector2(22, 14), 7, Color("696f85"))
	draw_rect(Rect2(0, 214, screen.x, 56), Color("4c485e"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 222), Vector2(70, 208), Vector2(132, 224), Vector2(214, 211), Vector2(286, 226), Vector2(390, 207), Vector2(480, 220), Vector2(480, 270), Vector2(0, 270)]), Color("69647a"))
	# Outpost silhouette on the surface.
	draw_rect(Rect2(340, 191, 76, 22), Color("b6b3a9"))
	draw_rect(Rect2(360, 180, 32, 12), Color("8bb9c0"))
	draw_rect(Rect2(320, 197, 20, 3), Color("e4c46e"))
	draw_rect(Rect2(418, 197, 20, 3), Color("e4c46e"))
	# Compact lander descends toward the habitat; flame pixels pulse beneath it.
	var progress := clampf(_elapsed / 1.55, 0.0, 1.0)
	var ship := Vector2(156 + progress * 99.0, 15 + progress * 117.0)
	draw_rect(Rect2(ship + Vector2(8, 8), Vector2(32, 18)), Color("b8ad91"))
	draw_rect(Rect2(ship + Vector2(12, 3), Vector2(24, 8)), Color("d7d4c2"))
	draw_rect(Rect2(ship + Vector2(15, 5), Vector2(17, 4)), Color("5a8ba1"))
	draw_rect(Rect2(ship + Vector2(4, 24), Vector2(4, 14)), Color("9397a4"))
	draw_rect(Rect2(ship + Vector2(40, 24), Vector2(4, 14)), Color("9397a4"))
	draw_rect(Rect2(ship + Vector2(2, 37), Vector2(9, 2)), Color("d5c69d"))
	draw_rect(Rect2(ship + Vector2(37, 37), Vector2(9, 2)), Color("d5c69d"))
	var flame_h := 5 + int(absf(sin(_elapsed * 16.0)) * 8.0)
	draw_rect(Rect2(ship + Vector2(16, 27), Vector2(4, flame_h)), Color("ffd16e"))
	draw_rect(Rect2(ship + Vector2(29, 27), Vector2(4, flame_h)), Color("ff9860"))
	var fade := clampf(_elapsed / 0.25, 0.0, 1.0)
	draw_rect(Rect2(0, screen.y - 27, screen.x, 27), Color(0.04, 0.07, 0.14, 0.86 * fade))
	draw_string(ThemeDB.fallback_font, Vector2(12, screen.y - 10), "LUNAR OUTPOST  /  TOUCHDOWN", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("b8f2e7", fade))


func _draw_graduation() -> void:
	var screen := get_viewport_rect().size
	var fade := clampf(1.0 - _elapsed / _duration, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.03, 0.06, 0.12, 0.26 * fade))
	var center := screen * 0.5
	var badge := Color("ffd36f", fade)
	draw_circle(center, 27, Color("162947", 0.94 * fade))
	draw_arc(center, 29, 0.0, TAU, 40, badge, 2.0)
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -17), center + Vector2(14, -9), center + Vector2(11, 9), center + Vector2(0, 18), center + Vector2(-11, 9), center + Vector2(-14, -9)]), Color("4a7d91", fade))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-7, 0), center + Vector2(-2, 5), center + Vector2(8, -6), center + Vector2(11, -3), center + Vector2(-2, 10), center + Vector2(-10, 3)]), badge)
	for i in 10:
		var angle := TAU * float(i) / 10.0 + _elapsed * 0.25
		var distance := 42.0 + fposmod(_elapsed * 30.0 + i * 7.0, 20.0)
		var pos := center + Vector2.RIGHT.rotated(angle) * distance
		draw_rect(Rect2(pos.round(), Vector2(2, 2)), Color("7ce2cd", fade))
	draw_string(ThemeDB.fallback_font, center + Vector2(-45, 49), "CERTIFICATION EARNED", HORIZONTAL_ALIGNMENT_LEFT, 110, 9, Color("e7e9f1", fade))
