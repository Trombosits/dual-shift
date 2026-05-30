extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"Richard: Hari yang melelahkan, tetapi juga sangat menyenangkan.",
	"Richard: Aku mempelajari banyak hal baru hari ini.",
	"Richard: Oh iya, aku hampir lupa.",
	"Richard: Master William memberiku sebuah buku pengembangan kemampuan.",
	"Richard: Beliau mengatakan bahwa untuk menguasai kemampuan tingkat tinggi, aku harus memahami dasar-dasarnya terlebih dahulu.",
	"Richard: Saat membuka buku itu, aku melihat setiap kemampuan terhubung dengan kemampuan lainnya.",
	"Richard: Beberapa kemampuan menjadi syarat untuk membuka kemampuan berikutnya.",
	"Richard: Strukturnya terlihat seperti cabang-cabang pohon.",
	"Richard: Master William menyebut konsep ini sebagai Tree.",
	"Richard: Pada struktur Tree terdapat hubungan antara induk dan cabang.",
	"Richard: Kemampuan dasar menjadi akar atau fondasi, kemudian berkembang menjadi kemampuan yang lebih tinggi.",
	"Richard: Artinya, aku tidak bisa langsung mempelajari kemampuan tingkat lanjut tanpa terlebih dahulu menguasai kemampuan yang menjadi syaratnya.",
	"Richard: Masuk akal juga..",
	"Richard: Baiklah, sebelum tidur aku akan mulai mempelajari buku ini.",
	"Richard: Siapa tahu suatu hari nanti aku bisa menjadi petualang hebat sekaligus resepsionis terbaik di Guild Hanseatic."

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
				get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")

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
