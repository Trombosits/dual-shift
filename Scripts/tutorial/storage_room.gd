extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"Jeanne: Kerja bagus hari ini, Richard.",
	"Jeanne: Guild sudah tutup dan para petualang telah pulang. Namun pekerjaan kita belum selesai.",
	"Richard: Masih ada tugas lain?",
	"Jeanne: Tentu saja.",
	"Jeanne: Sebagai resepsionis, kita juga bertanggung jawab membantu mengatur persediaan potion di ruang penyimpanan.",
	"Richard: Apakah ada aturan khusus juga untuk pekerjaan ini?",
	"Jeanne: Ada,  aturan ini sangat penting agar gudang tetap rapi dan mudah dikelola.",
	"Jeanne: Apakah kamu masih semangat untuk belajar?",
	"Richard: Tentu saja.",
	"Jeanne: Bagus.",
	"Jeanne: Pelajaran berikutnya adalah FILO atau yang lebih sering disebut LIFO, yaitu Last In First Out.",
	"Richard: Apa bedanya dengan FIFO?",
	"Jeanne: Mari kita lihat tumpukan potion ini.",
	"Jeanne: Saat potion baru datang, kita menaruhnya di bagian paling atas tumpukan.",
	"Jeanne: Kemudian saat kita membutuhkan satu potion, yang paling mudah diambil adalah potion yang berada di bagian atas.",
	"Jeanne: Artinya, potion yang terakhir masuk justru menjadi potion pertama yang keluar.",
	"Richard: Oh, jadi kebalikannya FIFO.",
	"Jeanne: Tepat sekali.",
	"Jeanne: Konsep ini disebut Stack atau tumpukan.",
	"Jeanne: Coba bayangkan jika kita memaksa mengambil potion yang paling bawah terlebih dahulu.",
	"Richard: Tumpukannya bisa runtuh.",
	"Jeanne: Benar sekali.",
	"Jeanne: Karena itu, pada struktur Stack, kita hanya menambah dan mengambil data dari bagian atas tumpukan.",
	"Richard: Sekarang aku mulai paham mengapa aturan ini digunakan.",
	"Jeanne: Bagus.",
	"Jeanne: Selain itu, ada satu aturan lagi yang harus kamu perhatikan.",
	"Jeanne: Yaitu melakukan pengelompokan atau sorting.",
	"Jeanne: Setiap jenis potion harus ditempatkan bersama dengan potion yang sejenis.",
	"Richard: Kenapa harus dipisahkan?",
	"Jeanne: Bayangkan ada petualang yang ingin membeli Health Potion.",
	"Jeanne: Jika semua jenis potion tercampur menjadi satu, kita akan membutuhkan waktu lama untuk mencarinya.",
	"Jeanne: Namun jika setiap jenis potion berada pada rak yang sesuai, kita dapat menemukannya dengan cepat.",
	"Richard: Jadi sorting membantu proses pencarian menjadi lebih mudah dan efisien.",
	"Jeanne: Tepat sekali.",
	"Jeanne: Seperti sebelumnya cara terbaik untuk belajar adalah dengan langsung mempraktikkannya.",
	"Richard: Baik, Jeanne. Aku akan berusaha sebaik mungkin."
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
				get_tree().change_scene_to_file("res://Scenes/gamemodes/tutorial_sorting/TutorSortingGame.tscn")

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
