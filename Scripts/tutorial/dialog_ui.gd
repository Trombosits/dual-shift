extends Control

signal text_animation_done

@onready var dialog_line = %Dialog_Line
@onready var speaker_name = %Speaker_Name
@onready var text_blip = %Text_Blip
@onready var text_timer = $Text_Timer
@onready var sentence_timer = $Sentence_Timer

const ANIMATION_SPEED : int = 30
const NO_SOUNDS_CHARS : Array =[".", "!", "?"]

var animate_text : bool = false
var current_visible_characters : int = 0
var current_character_details : Dictionary

func _ready() -> void:
	text_timer.timeout.connect(_on_text_blip_timeout)
	sentence_timer.timeout.connect(_on_sentence_pause_timeout)

func _process(delta):
	if animate_text:

		if sentence_timer.is_stopped():

			if dialog_line.visible_ratio < 1:

				dialog_line.visible_ratio += (1.0 / dialog_line.text.length()) * (ANIMATION_SPEED * delta)

				if dialog_line.visible_characters > current_visible_characters:

					current_visible_characters = dialog_line.visible_characters

					var current_char = dialog_line.text[current_visible_characters - 1]

					if current_visible_characters < dialog_line.text.length():

						var next_char = dialog_line.text[current_visible_characters]

						if NO_SOUNDS_CHARS.has(current_char) and next_char == " ":
							text_timer.stop()
							sentence_timer.start()

			else:
				dialog_line.visible_ratio = 1
				animate_text = false
				text_timer.stop()
				text_animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	speaker_name.text = current_character_details["name"]
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true
	text_timer.start()

func skip_text_animation():
	dialog_line.visible_ratio = 1
	animate_text = false

	text_timer.stop()
	sentence_timer.stop()

	text_animation_done.emit()

func _on_text_blip_timeout():
	text_blip.play_sound(current_character_details)
	
func _on_sentence_pause_timeout():
	text_timer.start()
