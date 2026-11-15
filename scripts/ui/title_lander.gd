extends Control
## Small hand-drawn lander for the title screen. Coordinates are rounded to pixels.

var _elapsed := 0.0
var _base_y := 0.0
var _direction := 1.0
var _thruster: CPUParticles2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base_y = position.y
	_thruster = CPUParticles2D.new()
	_thruster.position = Vector2(24, 34)
	_thruster.amount = 18
	_thruster.lifetime = 0.42
	_thruster.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_thruster.emission_rect_extents = Vector2(5, 1)
	_thruster.direction = Vector2(0, 1)
	_thruster.spread = 9.0
	_thruster.gravity = Vector2(0, 12)
	_thruster.initial_velocity_min = 9.0
	_thruster.initial_velocity_max = 19.0
	_thruster.scale_amount_min = 1.0
	_thruster.scale_amount_max = 2.0
	_thruster.color = Color("ffbf67")
	_thruster.emitting = true
	add_child(_thruster)


func _process(delta: float) -> void:
	_elapsed += delta
	var viewport_width := get_viewport_rect().size.x
	position.x += _direction * delta * 5.5
	if position.x > viewport_width + 12:
		position.x = -56
	elif position.x < -56:
		position.x = viewport_width + 12
	position.y = _base_y + roundf(sin(_elapsed * 1.1) * 2.0)
	queue_redraw()


func _draw() -> void:
	# Landing legs and footpads.
	_rect(6, 25, 3, 8, "8590a6")
	_rect(3, 32, 9, 2, "c6c5b8")
	_rect(39, 25, 3, 8, "8590a6")
	_rect(36, 32, 9, 2, "c6c5b8")
	# Body frame.
	_rect(14, 8, 20, 2, "e8d8aa")
	_rect(11, 10, 26, 2, "d2c19a")
	_rect(9, 12, 30, 11, "b5a783")
	_rect(12, 23, 24, 4, "958c79")
	_rect(16, 27, 16, 2, "776f68")
	# Cockpit, rim and blue glass.
	_rect(16, 3, 16, 2, "e9dfbf")
	_rect(13, 5, 22, 6, "c5d4d9")
	_rect(15, 6, 18, 4, "4d7890")
	_rect(17, 6, 7, 2, "90c3ce")
	_rect(25, 8, 7, 2, "31546c")
	# Equipment panels and antenna.
	_rect(12, 14, 5, 6, "687487")
	_rect(13, 15, 3, 1, "79c8bd")
	_rect(13, 17, 3, 1, "f0b65f")
	_rect(34, 14, 3, 4, "797668")
	_rect(22, 0, 2, 4, "d4d8cc")
	_rect(21, 0, 4, 1, "f2b762")
	# Thruster housings and alternating flame pixels.
	_rect(18, 29, 5, 4, "656a78")
	_rect(27, 29, 5, 4, "656a78")
	var flicker := int(_elapsed * 14.0) % 2 == 0
	_rect(19, 33, 3, 2 if flicker else 4, "ffcf69")
	_rect(28, 33, 3, 4 if flicker else 2, "ffcf69")
	_rect(20, 35, 1, 2, "ff8859")
	_rect(29, 35, 1, 2, "ff8859")


func _rect(x: int, y: int, width: int, height: int, color: String) -> void:
	draw_rect(Rect2(Vector2(x, y), Vector2(width, height)), Color(color))
