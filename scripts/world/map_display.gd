class_name MapDisplay
extends Control

signal selected(id: String)

const CYAN := Color("#67f5ef")
const AMBER := Color("#ffd27e")
var expanded := false
var zoom := 1.0
var pan := Vector2.ZERO
var _drag := false
var _travel := 0.0


func _gui_input(event: InputEvent) -> void:
	if not expanded or not is_instance_valid(MapManager.floor):
		return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					change_zoom(1.2 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.2)
					accept_event()
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					_drag = true
					_travel = 0.0
				elif _drag:
					_drag = false
					if _travel < 4.0:
						_pick(event.position)
				accept_event()
	elif event is InputEventMouseMotion and _drag:
		_travel += event.relative.length()
		pan += event.relative
		_limit_pan()
		queue_redraw()
		accept_event()


func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	_drag = false


func change_zoom(factor: float) -> void:
	zoom = clampf(zoom * factor, 1.0, 3.0)
	_limit_pan()
	queue_redraw()


func _limit_pan() -> void:
	var limit := size * (zoom - 1.0) * 0.5
	pan = pan.clamp(-limit, limit)


func _pick(at: Vector2) -> void:
	var best := 12.0
	var chosen := ""
	for id: String in MapManager.floor.points:
		var distance := at.distance_to(_screen(MapManager.floor.points[id]["at"]))
		if distance < best:
			chosen = id
			best = distance
	if not chosen.is_empty():
		selected.emit(chosen)


func _factor() -> float:
	var bounds: Vector2 = MapManager.floor.bounds
	return minf((size.x - 12.0) / bounds.x, (size.y - 12.0) / bounds.y) * zoom


func _screen(point: Vector2) -> Vector2:
	return (point - MapManager.floor.bounds / 2.0) * _factor() + size / 2.0 + pan


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0e162c"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#528eaa"), false)
	var floor_map = MapManager.floor
	if not is_instance_valid(floor_map):
		return
	for room: Rect2 in floor_map.floors:
		draw_rect(Rect2(_screen(room.position), room.size * _factor()), Color("#334762"))
	for obstacle: Rect2 in floor_map.blocked:
		draw_rect(Rect2(_screen(obstacle.position), obstacle.size * _factor()), Color("#1c283f"))
	var line := PackedVector2Array()
	for at: Vector2 in floor_map.route:
		line.append(_screen(at))
	if line.size() > 1:
		draw_polyline(line, CYAN, 1.5)
	var font := ThemeDB.fallback_font
	for id: String in floor_map.points:
		var point: Dictionary = floor_map.points[id]
		var at := _screen(point.at).round()
		var tracked := id == MapManager.local_target()
		var radius := 3.0 if expanded else 1.7
		var color := AMBER if tracked else Color("#b0bfd9")
		match String(point.kind):
			"crew":
				draw_circle(at, radius, color)
			"hatch":
				draw_rect(Rect2(at - Vector2.ONE * radius, Vector2.ONE * radius * 2), color, false)
			_:
				draw_colored_polygon(PackedVector2Array([at + Vector2(0, -radius), at + Vector2(radius, 0),
					at + Vector2(0, radius), at - Vector2(radius, 0)]), color)
		if tracked:
			draw_arc(at, radius + 2.0, 0.0, TAU, 12, AMBER, 1.0)
		if expanded:
			draw_string(font, at + Vector2(5, -3), point.short, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, color)
	var at := _screen(floor_map.player.position).round()
	draw_circle(at, 4.0 if expanded else 2.7, Color("#11202a"))
	draw_circle(at, 2.7 if expanded else 1.8, CYAN)
