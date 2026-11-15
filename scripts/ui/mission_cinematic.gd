extends Control
## Ten-second, skippable illustrated briefing. Captions are handled by Dialogue.

var _elapsed := 0.0
var _last_scene := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.45)


func _process(delta: float) -> void:
	_elapsed += delta
	var scene := mini(int(_elapsed / 3.1), 2)
	if scene != _last_scene:
		_last_scene = scene
		if scene == 1:
			Sfx.play(&"alert")
	queue_redraw()


func _draw() -> void:
	var screen := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, screen), Color("080d20", 0.94))
	for i in 42:
		var x := float((i * 83 + 29) % 480)
		var y := float((i * 47 + 17) % 270)
		var blink := 0.45 + absf(sin(_elapsed * 2.2 + i)) * 0.5
		draw_rect(Rect2(Vector2(x, y), Vector2(1, 1)), Color(0.75, 0.86, 1.0, blink))
	match _last_scene:
		0: _draw_destination(screen)
		1: _draw_space_weather(screen)
		_: _draw_academy(screen)


func _draw_destination(screen: Vector2) -> void:
	var drift := sin(_elapsed * 1.2) * 5.0
	var earth := Vector2(screen.x * 0.22, 95 + drift)
	draw_circle(earth, 26, Color("4388ae"))
	draw_arc(earth, 27, 0.4, 3.4, 24, Color("8ad1d2"), 3.0)
	var moon := Vector2(screen.x * 0.78, 145 - drift)
	draw_circle(moon, 53, Color("82869a"))
	draw_circle(moon + Vector2(18, -13), 8, Color("6c7185"))
	draw_circle(moon + Vector2(-20, 15), 11, Color("70768b"))
	# Tiny habitat silhouette on the lunar horizon.
	draw_rect(Rect2(moon.x - 12, moon.y - 21, 24, 11), Color("c4c0a6"))
	draw_rect(Rect2(moon.x - 6, moon.y - 29, 12, 8), Color("7db2bf"))
	draw_rect(Rect2(moon.x - 27, moon.y - 17, 13, 3), Color("e1c670"))
	draw_rect(Rect2(moon.x + 14, moon.y - 17, 13, 3), Color("e1c670"))


func _draw_space_weather(screen: Vector2) -> void:
	var sun := Vector2(screen.x * 0.28, screen.y * 0.45)
	draw_circle(sun, 25, Color("f6a64c"))
	draw_circle(sun, 18, Color("ffd878"))
	for ray in 9:
		var angle := float(ray) * TAU / 9.0 + _elapsed * 0.14
		var direction := Vector2.RIGHT.rotated(angle)
		draw_line(sun + direction * 30, sun + direction * (40 + float(ray % 3) * 3), Color("ff9d5b", 0.7), 2.0)
	for particle in 22:
		var progress := fposmod(_elapsed * (30.0 + particle % 6) + particle * 19.0, screen.x * 0.65)
		var y := 54.0 + float((particle * 31) % 155)
		draw_rect(Rect2(Vector2(sun.x + 34 + progress, y), Vector2(2, 2)), Color("ffcf79", 0.8))
	draw_circle(Vector2(screen.x * 0.78, 140), 47, Color("6e7489"))
	draw_rect(Rect2(screen.x * 0.74, 103, 36, 23), Color("ded5bd"))
	draw_rect(Rect2(screen.x * 0.78, 93, 14, 12), Color("83b6c2"))
	var flash := int(_elapsed * 5.0) % 2 == 0
	draw_rect(Rect2(screen.x * 0.77, 108, 4, 4), Color("ff614f") if flash else Color("5c313d"))


func _draw_academy(screen: Vector2) -> void:
	var center := Vector2(screen.x * 0.52, screen.y * 0.56)
	draw_rect(Rect2(center.x - 116, center.y - 47, 232, 109), Color("343852"))
	draw_rect(Rect2(center.x - 126, center.y - 52, 252, 12), Color("68738c"))
	draw_rect(Rect2(center.x - 17, center.y - 27, 34, 75), Color("263043"))
	draw_rect(Rect2(center.x - 101, center.y - 27, 28, 25), Color("78aebe"))
	draw_rect(Rect2(center.x + 73, center.y - 27, 28, 25), Color("78aebe"))
	# Training console, mentor silhouettes and astronaut recruit.
	draw_rect(Rect2(center.x - 74, center.y + 17, 34, 25), Color("2c303d"))
	draw_rect(Rect2(center.x - 69, center.y + 12, 24, 6), Color("6cd0ba"))
	for offset in [-85.0, 0.0, 85.0]:
		draw_circle(center + Vector2(offset, -4), 6, Color("efcf9e"))
		draw_rect(Rect2(center.x + offset - 6, center.y + 2, 12, 24), Color("8cb7c1"))
	draw_rect(Rect2(Vector2(0, screen.y - 37), Vector2(screen.x, 37)), Color("0c1227", 0.86))
