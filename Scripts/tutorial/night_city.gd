extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"Richard: Akhirnya selesai juga hari pertamaku bekerja di guild.",
	"Richard: Aku belajar banyak hal hari ini.",
	"Richard: Queue, Priority Queue, dan Stack.",
	"Richard: Hmm...",
	"Richard: Saat berburu monster, biasanya aku menyerang monster yang kutemui secara acak.",
	"Richard: Tapi setelah mempelajari Queue, aku punya ide.",
	"Richard: Bagaimana jika aku memburu monster sesuai urutan saat menemukannya?",
	"Richard: Monster pertama yang kutemui akan kuburu lebih dulu, kemudian monster berikutnya, dan seterusnya.",
	"Richard: Sama seperti FIFO yang diajarkan Jeanne. Yang datang lebih dulu akan diproses lebih dulu.",
	"Richard: Cara itu pasti membuat perburuanku lebih teratur.",
	"Richard: Tapi tunggu sebentar...",
	"Richard: Bagaimana jika saat sedang memburu monster biasa, tiba-tiba muncul monster yang jauh lebih berbahaya?",
	"Richard: Jika aku tetap mengikuti FIFO, monster berbahaya itu harus menunggu gilirannya.",
	"Richard: Padahal monster tersebut bisa mengancam keselamatanku dan warga sekitar.",
	"Richard: Situasi ini mirip seperti bangsawan yang mendapatkan prioritas di guild.",
	"Richard: Dalam kondisi seperti itu, monster yang lebih berbahaya seharusnya menjadi prioritas utama untuk diburu terlebih dahulu.",
	"Richard: Berarti aku tidak cukup hanya menggunakan Queue biasa.",
	"Richard: Aku juga perlu menerapkan Priority Queue.",
	"Richard: Dengan begitu, monster berbahaya akan diprioritaskan, sedangkan monster lainnya tetap menunggu giliran.",
	"Richard: Menarik sekali.",
	"Richard: Ternyata Queue dan Priority Queue tidak hanya berguna di meja resepsionis, tetapi juga dapat membantu saat berburu.",
	"Richard: Seperti kata Jeanne, cara terbaik untuk memahami suatu konsep adalah dengan mempraktikkannya secara langsung.",
	"Richard: Kalau begitu, aku akan pergi ke hutan dan mencobanya sekarang juga."
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
				get_tree().change_scene_to_file("res://Scenes/gamemodes/tutorial_typing/tutorial_Typing.tscn")

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
