extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"Richard: Akhirnya selesai juga hari pertamaku bekerja di guild.",
	"Richard: Aku belajar banyak hal hari ini.",
	"Richard: Aku tiba-tiba teringat pelajaran tentang antrean. Bagaimana jika aku terapkan pada perburuan.",
	"Richard: Biasanya aku menyerang monster yang kutemui secara acak.",
	"Richard: Namun sekarang aku berpikir, bagaimana jika aku membuat urutan target yang harus diburu?",
	"Richard: Tapi ada satu masalah.",
	"Richard: Beberapa monster jauh lebih berbahaya dibandingkan yang lain.",
	"Richard: Jika ada monster yang sangat kuat muncul, tentu aku harus menanganinya terlebih dahulu demi keselamatan.",
	"Richard: Berarti tidak cukup hanya menggunakan FIFO biasa.",
	"Richard: Aku perlu sistem yang tetap memiliki antrean, tetapi monster yang lebih berbahaya mendapatkan prioritas lebih tinggi.",
	"Richard: Hmm... sistem seperti itu bisa disebut Priority Queue.",
	"Richard: Dengan begitu, target yang paling penting akan ditangani lebih dahulu tanpa membuat perburuan menjadi kacau.",
	"Richard: Seperti kata Jeanne Cara terbaik untuk belajar adalah dengan langsung mempraktikkannya.",
	"Richard: Aku akan langsung pergi ke Hutan sekarang juga."
]

func _ready():
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_index = 0
	process_current_line()

func _input(event):
	if event.is_action_pressed("next_line"):

		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()

		else:

			if dialog_index < len(dialog_line) - 1:
				dialog_index += 1
				process_current_line()

			else:
				get_tree().change_scene_to_file("res://Scenes/tutorial/player_room.tscn")

func parse_line(line: String):
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

func process_current_line():
	var line = dialog_line[dialog_index]
	var line_info = parse_line(line)
	var character_name = Character.get_enum_from_string(line_info["speaker_name"])
	dialog_ui.change_line(character_name, line_info["dialog_line"])
	character_sprite.change_character(character_name)

func _on_text_animation_done():
	character_sprite.play_idle_animation()
