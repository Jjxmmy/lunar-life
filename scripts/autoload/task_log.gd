extends Node
## Reads progression from its existing owners and records completed mentor visits.

signal changed

const MENTORS: Array[StringName] = [&"commander", &"engineer", &"botanist"]


func _ready() -> void:
	EventBus.dialogue_ended.connect(_record_mentor)
	EventBus.flag_set.connect(func(_flag: StringName, _value: Variant) -> void: changed.emit())
	MissionDirector.stage_changed.connect(func(_stage: int) -> void: changed.emit())
	MissionDirector.objectives_changed.connect(func() -> void: changed.emit())
	EventBus.dialogue_ended.connect(func(_id: StringName) -> void: changed.emit())


func _record_mentor(id: StringName) -> void:
	if id in MENTORS:
		GameState.set_flag(StringName("mentor_" + String(id)))
	changed.emit()


func current_objective() -> Dictionary:
	var wanted_id := ""
	match MissionDirector.stage:
		MissionDirector.Stage.BRIEFING:
			wanted_id = "Speak with the mentors"
		MissionDirector.Stage.TRAINING:
			for id: String in ["Sort the selection cards", "Find Engineer Rivera", "Complete power console training", "Robotic arm drill"]:
				for task in entries():
					if task.get("id", "") == id and not task.done:
						return task
		MissionDirector.Stage.GRADUATED:
			wanted_id = "Graduate and travel to the outpost" if MissionDirector.academy_done() else ("Robotic arm drill" if not GameState.get_flag(&"day1_arm") else "Sort the selection cards")
		MissionDirector.Stage.CHECKS:
			for task in entries():
				if task.get("facility", "") == "Outpost" and not task.done:
					return task
			return {}
		MissionDirector.Stage.ALERT:
			wanted_id = "Respond to the space weather alert"
	for task in entries():
		if task.get("id", "") == wanted_id and not task.done:
			return task
	return {}


func entries() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var d := MissionDirector
	_add(list, "Create your astronaut", "Choose a name and suit in the recruitment screen.", GameState.get_flag(&"astronaut_created"))
	if not GameState.get_flag(&"astronaut_created"):
		return list

	_add(list, "Explore the academy", "Visit the space-weather desk, the power lab and the plant lab.", GameState.get_flag(&"academy_explored"))
	var mentors_met := 0
	for mentor in MENTORS:
		if GameState.get_flag(StringName("mentor_" + String(mentor))):
			mentors_met += 1
	_add(list, "Speak with the mentors (%d/3)" % mentors_met, "Find Okafor, Rivera and Tanaka in the academy.", mentors_met == 3)
	if d.stage >= d.Stage.TRAINING:
		_add(list, "Sort the selection cards", "Talk to Commander Okafor and sort real astronaut requirements from myths.", GameState.get_flag(&"day1_selection"))
		_add(list, "Robotic arm drill", "Capture three cargo ships with the robotics trainer in the east wing.", GameState.get_flag(&"day1_arm"))
		_add(list, "Find Engineer Rivera", "Visit the east training workshop and talk to Rivera.", GameState.get_flag(&"mentor_engineer"))
		_add(list, "Complete power console training", "Postpone a load and keep the battery above empty.", d.can_graduate())
		_add(list, "Earn your certification", "Pass the training scenario to earn the certificate.", d.can_graduate())
	if d.academy_done():
		_add(list, "Graduate and travel to the outpost", "Take the launch hatch on the academy's north-east wall.", GameState.get_flag(&"outpost_visited"))
	if GameState.get_flag(&"outpost_visited"):
		for task: Dictionary in d.today_tasks():
			_add(list, str(task["title"]), str(task["description"]), d.is_task_done(StringName(str(task["id"]))), str(task.get("destination", "")))
		if d.stage == d.Stage.CHECKS and not d.is_final_day():
			_add(list, "Write the evening log", "Use the comms desk in the corridor to log what you learned today.", d.log_written, "log")
			_add(list, "Sleep in your bunk", "Rest in a sleep pod in the corridor to start Day %d." % (d.day + 1), false, "bunk")
	if d.stage >= d.Stage.ALERT:
		var alert_help := "Run north. Hold E to crank the shelter hatch open, then step inside."
		if d.stage == d.Stage.DEBRIEF and not d.reached_shelter:
			alert_help = "The crew missed shelter. Retry from the debrief to try again."
		_add(list, "Respond to the space weather alert", alert_help, d.reached_shelter)
	return list


func _add(list: Array[Dictionary], title: String, description: String, done: bool, outpost_spot: String = "") -> void:
	var id := title.split(" (")[0]
	var destination: Array = {
		"Explore the academy": ["Academy", "briefing"],
		"Find Engineer Rivera": ["Academy", "rivera"],
		"Complete power console training": ["Academy", "rivera"],
		"Earn your certification": ["Academy", "rivera"],
		"Sort the selection cards": ["Academy", "commander"],
		"Robotic arm drill": ["Academy", "arm"],
		"Graduate and travel to the outpost": ["Outpost", "entrance"],
		"Check outpost power": ["Outpost", "power"],
		"Check the greenhouse": ["Outpost", "crops"],
	}.get(id, [])
	if not outpost_spot.is_empty():
		destination = ["Outpost", outpost_spot]
	if id == "Respond to the space weather alert" and MissionDirector.stage == MissionDirector.Stage.ALERT:
		destination = ["Outpost", "shelter"]
	if id == "Speak with the mentors":
		for mentor in MENTORS:
			if not GameState.get_flag(StringName("mentor_" + String(mentor))):
				destination = ["Academy", {"commander": "commander", "engineer": "rivera", "botanist": "botanist"}[String(mentor)]]
				break
	if id == "Explore the academy":
		var zones: int = GameState.get_flag(&"academy_zones", 0)
		for i in 3:
			if not (zones & (1 << i)):
				destination = ["Academy", ["commander", "rivera", "botanist"][i]]
				break
	var entry := {"id": id, "title": title, "description": description, "done": done}
	if not destination.is_empty():
		entry["facility"] = destination[0]
		entry["destination"] = destination[1]
	list.append(entry)

