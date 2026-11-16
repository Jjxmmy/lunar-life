extends Node
## Developer check: opens each hands-on lesson mid-way and saves a rendered screenshot
## to tools/shots/lesson_*.png. Run without --headless.

const CASES := [
	["res://scripts/minigames/academy_lesson.gd", &"suit", {"_step": 3, "_choice": 3}],
	["res://scripts/minigames/academy_lesson.gd", &"pool", {"_score": 1, "_position": Vector2(250, 150)}],
	["res://scripts/minigames/hands_on_lesson.gd", &"plant", {"_step": 1, "_water": 62.0}],
	["res://scripts/minigames/hands_on_lesson.gd", &"health", {"_score": 5}],
	["res://scripts/minigames/later_mission_lesson.gd", &"regolith", {"_score": 0, "_choice": 0}],
	["res://scripts/minigames/later_mission_lesson.gd", &"harvest", {"_score": 1, "_collected": [0], "_position": Vector2(290, 175)}],
	["res://scripts/minigames/hands_on_lesson.gd", &"plant", {"_step": 3, "_result": true, "_mistakes": 1}],
	["res://scripts/minigames/day4_lesson.gd", &"weather", {"_score": 2, "_event": 0, "_event_t": 0.8, "_answered": true, "_feedback": "Good catch! A flare is a bright flash."}],
	["res://scripts/minigames/day4_lesson.gd", &"message", {"_step": 3, "_signal": 4.0}],
]


func _ready() -> void:
	await get_tree().process_frame
	var bg := ColorRect.new()
	bg.color = Color("3a4466")
	bg.size = Vector2(480, 270)
	add_child(bg)
	for i in CASES.size():
		var spec: Array = CASES[i]
		var lesson := CanvasLayer.new()
		lesson.set_script(load(spec[0]))
		lesson.set("kind", spec[1])
		add_child(lesson)
		for key: String in spec[2]:
			lesson.set(key, spec[2][key])
		for f in 40:
			await get_tree().process_frame
		var img := get_viewport().get_texture().get_image()
		img.save_png("res://tools/shots/lesson_%d_%s.png" % [i, spec[1]])
		lesson.queue_free()
		await get_tree().process_frame
	get_tree().quit()
