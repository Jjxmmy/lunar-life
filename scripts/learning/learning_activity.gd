class_name LearningActivity
extends Node
## Runs one interactive learning activity from data/learning/activities.json as a short
## chain of ChoicePanels: answer -> instant feedback with the reason -> next.
##
## Kinds (all use the same flow, only the wording changes):
##   "quiz"    - pick the right answer
##   "predict" - make a prediction, then see what really happens
##   "sort"    - put each item into the right group (the options are the groups)
##
## Esc on a question gives up the activity: `cancelled` fires and nothing is completed,
## so a task can never be finished without actually doing it.
##   var act := LearningActivity.start(self, &"selection")
##   act.finished.connect(func(correct: int, total: int) -> void: ...)

signal finished(correct: int, total: int)
signal cancelled

const DATA_PATH := "res://data/learning/activities.json"

static var _all: Dictionary = {}

var activity_id: StringName
var _data: Dictionary = {}
var _index: int = 0
var _correct: int = 0
var _over: bool = false


static func start(parent: Node, id: StringName) -> LearningActivity:
	var act := LearningActivity.new()
	act.activity_id = id
	act.name = "Activity_%s" % id
	parent.add_child(act)
	return act


static func get_data(id: StringName) -> Dictionary:
	if _all.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if parsed is Dictionary:
			_all = (parsed as Dictionary).get("activities", {})
		else:
			push_error("LearningActivity: could not read %s" % DATA_PATH)
	return _all.get(String(id), {})


func _ready() -> void:
	_data = get_data(activity_id)
	if _data.is_empty():
		push_error("LearningActivity: unknown activity '%s'" % activity_id)
		_finish()
		return
	var intro := str(_data.get("intro", ""))
	if intro.is_empty():
		_ask.call_deferred()
	else:
		var panel := ChoicePanel.open(get_parent(), str(_data["title"]), intro, PackedStringArray(["Start"]))
		panel.chosen.connect(func(_i: int) -> void: _ask.call_deferred())
		panel.closed.connect(_cancel)


func _items() -> Array:
	return _data.get("items", [])


func _ask() -> void:
	var items := _items()
	if _index >= items.size():
		_summary()
		return
	var item: Dictionary = items[_index]
	var kind := str(_data.get("kind", "quiz"))
	var options: PackedStringArray = PackedStringArray(_data.get("bins", [])) if kind == "sort" else PackedStringArray(item.get("options", []))
	var heading := {"quiz": "QUESTION", "predict": "PREDICT", "sort": "SORT"}.get(kind, "QUESTION") as String
	var title := "%s  %d of %d" % [heading, _index + 1, items.size()]
	var text := str(item.get("text", ""))
	if kind == "sort":
		text = "Where does this belong?\n\n\"%s\"" % text
	var panel := ChoicePanel.open(get_parent(), title, text, options)
	panel.chosen.connect(_answer)
	panel.closed.connect(_cancel)


func _answer(choice: int) -> void:
	var item: Dictionary = _items()[_index]
	var kind := str(_data.get("kind", "quiz"))
	var right := int(item.get("bin" if kind == "sort" else "answer", 0))
	var options: Array = _data.get("bins", []) if kind == "sort" else item.get("options", [])
	var ok := choice == right
	if ok:
		_correct += 1
	# Words carry the verdict, colour only repeats it.
	var verdict := "CORRECT" if ok else "NOT QUITE"
	if kind == "predict":
		verdict = "GOOD PREDICTION" if ok else "SURPRISE"
	var body := ""
	if not ok:
		body = "Answer: %s\n\n" % str(options[right])
	body += str(item.get("explain", ""))
	_index += 1
	var last := _index >= _items().size()
	var panel := ChoicePanel.open(get_parent(), ("+  " if ok else "x  ") + verdict, body, PackedStringArray(["Finish" if last else "Next"]), false)
	Sfx.play(&"confirm" if ok else &"cancel")
	panel.chosen.connect(func(_i: int) -> void: _ask.call_deferred())


func _summary() -> void:
	var total := _items().size()
	var body := "You got %d of %d right.\n\n%s" % [_correct, total, str(_data.get("outro", ""))]
	for note: String in _data.get("notes", []):
		FieldNotes.unlock(StringName(note))
	var panel := ChoicePanel.open(get_parent(), str(_data["title"]) + "  -  DONE", body, PackedStringArray(["Done"]), false)
	panel.chosen.connect(func(_i: int) -> void: _finish())


func _finish() -> void:
	if _over:
		return
	_over = true
	finished.emit(_correct, _items().size())
	queue_free()


func _cancel() -> void:
	if _over:
		return
	_over = true
	cancelled.emit()
	queue_free()
