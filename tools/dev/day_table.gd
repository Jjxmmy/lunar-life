extends Node
## Developer check for the five-day mission: plays days 2-4 (with each night simulated)
## and the day-5 storm for several night lengths and power habits, and prints where the
## battery, crops and ratings end up. Used to tune night_hours in sep_replay_config.json.
##   Godot --headless --path . res://tools/dev/day_table.tscn


func _ready() -> void:
	var D := MissionDirector
	GameState.earn_certification(&"power_console")
	print("night rover green | d5 batt crops  | expo battMin LS shut crops sci | stars")
	for night in [4, 6, 8, 10, 12]:
		D.config["night_hours"] = night
		for rover in [0, 1]:
			for green in [0, 1]:
				D.begin_mission()
				for day in 3:
					ResourceSim.set_load_enabled(&"rover", rover == 1)
					ResourceSim.set_greenhouse_conservation(green == 1)
					D.tasks_done = {}
					for task: Dictionary in D.today_tasks():
						D.tasks_done[StringName(str(task["id"]))] = true
					D.log_written = true
					D.sleep()
				var morning_batt := ResourceSim.battery
				var morning_crops := ResourceSim.crop_health
				ResourceSim.set_load_enabled(&"rover", rover == 1)
				ResourceSim.set_greenhouse_conservation(green == 1)
				for task: Dictionary in D.today_tasks():
					D.tasks_done[StringName(str(task["id"]))] = true
				D.start_alert()
				ResourceSim.advance_hour()   # one hour outside: a quick run to the shelter
				D.hours_unsheltered = 1
				D.storm_hours_done = 1
				D.reached_shelter = true
				D.shelter_choice = 2
				ResourceSim.crew_sheltered = true
				ResourceSim.set_load_enabled(&"rover", false)
				ResourceSim.set_load_enabled(&"greenhouse", true)
				ResourceSim.set_load_enabled(&"science", false)
				ResourceSim.set_greenhouse_conservation(true)
				for i in D.storm_hours_total() - 1:
					ResourceSim.advance_hour()
				D.stage = D.Stage.DEBRIEF
				var r := MissionReport.rate()
				print("%5d %5d %5d | %7.1f %5d | %4.1f %7.1f %2d/%2d %4d %5d %3d | %d+%d+%d" % [night, rover, green,
					morning_batt, int(morning_crops), ResourceSim.exposure_log, ResourceSim.battery_min,
					ResourceSim.life_support_ok_hours, ResourceSim.hours_run, ResourceSim.emergency_shutoffs,
					int(ResourceSim.crop_health), ResourceSim.science_points, r["safety"], r["power"], r["yield"]])
	get_tree().quit()
