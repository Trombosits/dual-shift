extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"William: Hey, anak muda. Selamat datang di Guild Hanseatic.",
	"William: Perkenalkan, namaku William Marshal. Aku adalah Guild Master yang memimpin guild ini. Siapa namamu?",
	"Richard: Perkenalkan, namaku Richard. Senang bertemu denganmu, Master William.",
	"William: Ah, jadi kau Richard. Aku mendengar kau datang ke sini atas rekomendasi Pak Tua Rodrigo. Benarkah?",
	"Richard: Benar, Master. Aku cukup berpengalaman dalam melayani pelanggan. Kebetulan aku mendengar guild ini sedang membutuhkan seorang resepsionis.",
	"Richard: Pak Tua Rodrigo menyarankan agar aku mencoba melamar di sini.",
	"William: Bagus. Rekomendasi dari Rodrigo bukanlah sesuatu yang diberikan sembarangan. Itu berarti ia melihat potensi dalam dirimu.",
	"William: Namun bekerja di guild tidak hanya membutuhkan keramahan. Seorang resepsionis juga harus mampu mengatur informasi, melayani petualang dengan tertib, serta menjaga alur pekerjaan agar tetap efisien.",
	"William: Karena itu, ada beberapa aturan dan metode kerja yang harus kau pelajari.",
	"William: Jeanne akan membimbingmu. Dengarkan baik-baik apa yang ia ajarkan, karena pengetahuan itu akan sangat berguna selama kau bekerja di sini.",
	"Richard: Saya mengerti, Master. Saya akan belajar dengan sungguh-sungguh."
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
				get_tree().change_scene_to_file("res://Scenes/tutorial/guild_room.tscn")

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
