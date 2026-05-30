class_name Character
extends Node

enum Name {
	RICHARD,
	WILLIAM,
	JEANNE
}

const CHARACTER_DETAILS : Dictionary = {
	Name.RICHARD: {
		"name": "Richard",
		"gender": "male",
		"sprite_frames": preload("res://assets/Sprites/dialogue/richard_dialogue.tres")
	},
	Name.WILLIAM: {
		"name": "William",
		"gender": "male",
		"sprite_frames": preload("res://assets/Sprites/dialogue/william_dialogue.tres")
	},
	
	Name.JEANNE: {
		"name": "Jeanne",
		"gender": "female",
		"sprite_frames": preload("res://assets/Sprites/dialogue/jeanne_dialogue.tres")
	}
}

static  func get_enum_from_string(string_value: String) -> int:
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		push_error("Invalid Character name: " + string_value)
		return -1
