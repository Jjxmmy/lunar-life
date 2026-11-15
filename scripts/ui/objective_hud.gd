extends CanvasLayer
## Compact current objective and a pulsing direction cue for the existing map target.

var navigation: NavigationFloor
var _panel: PanelContainer
var _label: Label
var _arrow: Control
var _objective_id := ""
var _title := ""
var _next_title := ""
var _completed_time := 0.0
var _pulse := 0.0
var _manual_navigation := false
var _change_tween: Tween


func _ready() -> void:
	layer = 22
	process_mode = Node.PROCESS_MODE_ALWAYS
	var theme := Theme.new()
	theme.default_font_size = 8
	theme.set_stylebox("panel", "PanelContainer", _panel_style())
	_panel = PanelContainer.new()
	_panel.theme = theme
	_panel.position = Vector2(6, 6)
	_panel.custom_minimum_size = Vector2(174, 20)
	add_child(_panel)
	_label = Label.new()
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.add_child(_label)
	_arrow = Control.new()
	_arrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_arrow.set_script(load("res://scripts/ui/objective_arrow.gd"))
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_arrow)
	TaskLog.changed.connect(_refresh)
	MapManager.waypoint_changed.connect(_on_waypoint_changed)
	MissionDirector.stage_changed.connect(func(_stage: int) -> void: _refresh())
	MissionDirector.objectives_changed.connect(_refresh)
	EventBus.flag_set.connect(func(_flag: StringName, _value: Variant) -> void: _refresh())
	_refresh()


func configure(floor: NavigationFloor) -> void:
	navigation = floor
	_arrow.call(&"configure", floor)
	_refresh()


func _process(delta: float) -> void:
	var hidden := Dialogue.is_active or MissionDirector.ui_open or SceneRouter.is_transitioning() or get_tree().paused
	_panel.visible = not hidden and not _title.is_empty()
	_arrow.visible = not hidden and navigation != null and _has_target()
	if hidden:
		return
	_pulse += delta
	if _completed_time > 0.0:
		_completed_time -= delta
		if _completed_time <= 0.0:
			_title = _next_title
			_next_title = ""
			_label.text = "▸ " + _title if not _title.is_empty() else ""
func _refresh() -> void:
	var previous_id := _objective_id
	var was_tracking_previous := not previous_id.is_empty() and MapManager.tracked_task == previous_id
	var task := TaskLog.current_objective()
	var next_id := str(task.get("id", ""))
	var next_title := str(task.get("title", ""))
	if next_id != _objective_id:
		var previous_done := false
		for entry in TaskLog.entries():
			if entry.get("id", "") == _objective_id:
				previous_done = entry.done
				break
		if previous_done and not _title.is_empty():
			_next_title = next_title
			_label.text = "✓ " + _title
			_completed_time = 0.65
		else:
			_title = next_title
			_next_title = ""
			_label.text = "▸ " + _title if not _title.is_empty() else ""
			_completed_time = 0.0
		if not next_title.is_empty():
			_animate_change()
		_objective_id = next_id
	var facility := str(task.get("facility", ""))
	var destination := str(task.get("destination", ""))
	var no_waypoint_selected := MapManager.target_id.is_empty() and MapManager.tracked_task.is_empty()
	if navigation != null and not _manual_navigation and not facility.is_empty() and not destination.is_empty() and (no_waypoint_selected or was_tracking_previous or MapManager.tracked_task == _objective_id):
		MapManager.set_waypoint(facility, destination, _objective_id)
	elif _objective_id.is_empty() and MapManager.tracked_task != "":
		MapManager.clear_waypoint()


func _on_waypoint_changed(_facility: String, id: String, task: String) -> void:
	if not id.is_empty() and task.is_empty():
		_manual_navigation = true
	elif not task.is_empty():
		_manual_navigation = false


func _animate_change() -> void:
	if _change_tween != null and _change_tween.is_running():
		_change_tween.kill()
	_panel.position = Vector2(0, 6)
	_panel.modulate.a = 0.65
	_change_tween = create_tween().set_parallel()
	_change_tween.tween_property(_panel, "position:x", 6.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_change_tween.tween_property(_panel, "modulate:a", 1.0, 0.18)


func _has_target() -> bool:
	var local_id := MapManager.local_target()
	return navigation != null and navigation.points.has(local_id) and not MapManager.target_id.is_empty()


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("111c32", 0.92)
	style.border_color = Color("62c7cd")
	style.set_border_width_all(1)
	style.set_content_margin_all(4)
	return style
