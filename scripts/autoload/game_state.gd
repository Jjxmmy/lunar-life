extends Node
## GameState — player profile, progression flags, certifications and score (autoload).
## Other systems READ from here; they change it only through the functions below,
## so every change is announced on the EventBus.

const SCORE_AXES: Array[StringName] = [
	&"crew_safety", &"sustainability", &"science", &"efficiency", &"training",
]
const SAVE_PATH := "user://lunar_life_save.json"

var player_name: String = "Recruit"
var suit_color: Color = Color(0.95, 0.55, 0.2)
var certifications: Array[StringName] = []
var flags: Dictionary = {}   # StringName -> Variant
var scores: Dictionary = {}  # StringName -> int


func _ready() -> void:
	for axis in SCORE_AXES:
		scores[axis] = 0
	# Example of decoupling: the simulation never touches the score directly.
	# It announces a brownout; GameState decides what that costs.
	EventBus.brownout.connect(_on_brownout)
	load_progress()


func set_flag(flag: StringName, value: Variant = true) -> void:
	flags[flag] = value
	EventBus.flag_set.emit(flag, value)
	save_progress()


func get_flag(flag: StringName, default: Variant = false) -> Variant:
	return flags.get(flag, default)


func add_score(axis: StringName, amount: int) -> void:
	if not scores.has(axis):
		push_warning("GameState: unknown score axis '%s'" % axis)
		return
	scores[axis] += amount
	EventBus.score_changed.emit(axis, scores[axis])
	save_progress()


func earn_certification(cert_id: StringName) -> void:
	if cert_id in certifications:
		return
	certifications.append(cert_id)
	EventBus.certification_earned.emit(cert_id)
	save_progress()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_progress() -> void:
	var data := {
		"player_name": player_name,
		"suit_color": suit_color.to_html(true),
		"certifications": certifications.map(func(value: StringName) -> String: return str(value)),
		"flags": flags,
		"scores": scores,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("GameState: could not save progress.")
		return
	file.store_string(JSON.stringify(data))


func load_progress() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var data: Dictionary = parsed
	player_name = str(data.get("player_name", "Recruit"))
	suit_color = Color.from_string(str(data.get("suit_color", "f28c33")), Color(0.95, 0.55, 0.2))
	certifications.clear()
	for cert: Variant in data.get("certifications", []):
		certifications.append(StringName(str(cert)))
	flags = data.get("flags", {})
	scores = data.get("scores", {})
	for axis in SCORE_AXES:
		scores[axis] = int(scores.get(axis, 0))
	return true


func start_fresh_progress() -> void:
	player_name = "Recruit"
	suit_color = Color(0.95, 0.55, 0.2)
	certifications.clear()
	flags.clear()
	for axis in SCORE_AXES:
		scores[axis] = 0
	save_progress()


func _on_brownout(_load_id: StringName) -> void:
	add_score(&"crew_safety", -1)
