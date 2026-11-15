class_name NavigationFloor
extends Node2D
## Builds the map and the routing grid from the facility's floors and physics.

const CELL := 8
const CYAN := Color("#67f5ef")
var facility: String
var bounds: Vector2
var floors: Array[Rect2] = []
var points: Dictionary = {}
var links: Dictionary = {}
var player: Node2D
var grid := AStarGrid2D.new()
var blocked: Array[Rect2] = []
var route := PackedVector2Array()
var arrows := true
var _built := false
var _elapsed := 1.0
var _pulse := 0.0


func add_point(id: String, title: String, short: String, description: String, kind: String, at: Vector2, actor: Node2D = null) -> void:
	points[id] = {"title": title, "short": short, "description": description, "kind": kind, "at": at, "actor": actor}


func _physics_process(delta: float) -> void:
	if not _built:
		_build_grid()
		MapManager.attach(self)
	_elapsed += delta
	if _elapsed >= 0.16:
		_elapsed = 0.0
		for point: Dictionary in points.values():
			if is_instance_valid(point.actor):
				point.at = point.actor.position
		MapManager.update_route(self)
	_pulse += delta
	if not route.is_empty():
		queue_redraw()


func _build_grid() -> void:
	grid.region = Rect2i(Vector2i.ZERO, Vector2i((bounds / CELL).ceil()))
	grid.cell_size = Vector2(CELL, CELL)
	grid.offset = grid.cell_size / 2.0
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	var query := PhysicsShapeQueryParameters2D.new()
	var foot := CircleShape2D.new()
	foot.radius = 5.5
	query.shape = foot
	query.exclude = [(player as CollisionObject2D).get_rid()]
	var space := get_world_2d().direct_space_state
	for y in grid.region.size.y:
		for x in grid.region.size.x:
			var id := Vector2i(x, y)
			var at := grid.get_point_position(id)
			var on_floor := floors.any(func(floor: Rect2) -> bool: return floor.has_point(at))
			query.transform = Transform2D(0.0, player.get_parent().to_global(at - Vector2(0, 4)))
			if not on_floor or not space.intersect_shape(query, 1).is_empty():
				grid.set_point_solid(id)
				if on_floor:
					blocked.append(Rect2(at - grid.offset, grid.cell_size))
	_built = true


func find_route(destination: Vector2) -> PackedVector2Array:
	var start := _nearest(player.position)
	var goal := _nearest(destination)
	if start.x < 0 or goal.x < 0:
		return PackedVector2Array()
	return grid.get_point_path(start, goal)


func _nearest(at: Vector2) -> Vector2i:
	var center := Vector2i((at / CELL).floor())
	var best := Vector2i(-1, -1)
	var distance := INF
	for y in range(center.y - 3, center.y + 4):
		for x in range(center.x - 3, center.x + 4):
			var id := Vector2i(x, y)
			if not grid.is_in_boundsv(id) or grid.is_point_solid(id):
				continue
			var squared := at.distance_squared_to(grid.get_point_position(id))
			if squared < distance:
				best = id
				distance = squared
	return best


func _draw() -> void:
	if not arrows:
		return
	for i in range(2, mini(route.size() - 1, 14), 3):
		var direction := route[i].direction_to(route[i + 1])
		var side := direction.orthogonal()
		var at := route[i]
		var shade := Color(CYAN, 0.65 + sin(_pulse * 5.0 - i * 0.55) * 0.28)
		draw_polyline(PackedVector2Array([
			at - direction * 3.0 + side * 3.0,
			at + direction * 3.0,
			at - direction * 3.0 - side * 3.0]), shade, 2.0)
