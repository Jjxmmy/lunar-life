class_name Station
extends Node2D
## A spot in the world the player can use by walking up and pressing E.
## Connect to `used`. Set `enabled = false` to hide its prompt.

signal used

var prompt: String = "Use"
var interaction_verb: String = "Use"
var enabled: bool = true
var objective_id: StringName = &""


func _ready() -> void:
	add_to_group(&"interactable")
	if objective_id != &"":
		add_to_group(&"objective_targets")


func prompt_text() -> String:
	return interaction_verb


func get_objective_id() -> StringName:
	return objective_id


func interact() -> void:
	if enabled:
		used.emit()
