class_name HabitatCamera
extends Camera2D
## Follow the interpolated player and clamp the view to the habitat.


static func mount(player: Node2D, bounds: Vector2i) -> void:
	var camera := HabitatCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = bounds.x
	camera.limit_bottom = bounds.y
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 9.0
	player.add_child(camera)
	camera.reset_physics_interpolation()
	camera.reset_smoothing()
	camera.force_update_scroll()



## Talk zoom: while a dialogue runs with an NPC or crew member next to the player, ease in
## to 2x (a whole number, so pixels stay crisp once it settles) framed on both of them and
## lifted above the dialogue box; ease back out when the dialogue ends.
const TALK_ZOOM := 2.0
const TALK_RANGE := 60.0
var _talk := 0.0


func _process(delta: float) -> void:
	var partner := _talk_partner() if Dialogue.is_active else null
	var target := 1.0 if partner != null else 0.0
	_talk = move_toward(_talk, target, delta * 3.0)
	var eased := _talk * _talk * (3.0 - 2.0 * _talk)
	var z := lerpf(1.0, TALK_ZOOM, eased)
	if _talk >= 1.0 or _talk <= 0.0:
		z = roundf(z)
	zoom = Vector2(z, z)
	var aim := Vector2.ZERO
	if partner != null:
		aim = (partner.global_position - get_parent().global_position) * 0.5 + Vector2(0, 22)
	offset = offset.lerp(aim * eased, minf(1.0, delta * 6.0)).round() if _talk > 0.0 else Vector2.ZERO


func _talk_partner() -> Node2D:
	var me := get_parent() as Node2D
	var best: Node2D = null
	var best_d := TALK_RANGE
	for node in get_tree().get_nodes_in_group(&"interactable"):
		if node is Node2D and (node is CrewMember or node is Npc):
			var d := me.global_position.distance_to((node as Node2D).global_position)
			if d < best_d:
				best_d = d
				best = node
	return best
