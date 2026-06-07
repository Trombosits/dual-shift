extends Node2D

@onready var character_sprite = %Character_Sprite
@onready var dialog_ui = %Dialog_UI

var dialog_index : int = 0

const dialog_line : Array[String] = [
	"Jeanne: Halo, Richard. Perkenalkan, namaku Jeanne d'Arc.",
	"Jeanne: Master William memintaku untuk membimbingmu selama masa pelatihan. Sebagai resepsionis, kamu akan menjadi orang pertama yang ditemui oleh para petualang ketika mereka datang ke guild.",
	"Jeanne: Karena itu, pekerjaan ini membutuhkan keteraturan dan ketelitian.",
	"Jeanne: Apakah kamu siap untuk belajar?",
	"Richard: Tentu saja. Aku sudah tidak sabar untuk memulai.",
	"Jeanne: Semangat yang bagus.",
	"Jeanne: Baiklah, pelajaran pertama hari ini adalah FIFO.",
	"Richard: FIFO?",
	"Jeanne: Benar. FIFO adalah singkatan dari First In First Out, yang berarti 'yang masuk pertama akan keluar pertama'.",
	"Jeanne: Bayangkan ada lima petualang yang datang ke meja resepsionis untuk mengambil misi.",
	"Jeanne: Petualang pertama yang datang tentu harus dilayani lebih dahulu. Setelah urusannya selesai, barulah petualang kedua dilayani, kemudian petualang ketiga, dan seterusnya.",
	"Jeanne: Dengan cara ini, semua orang mendapatkan giliran yang adil dan tidak ada yang merasa didahulukan secara tidak semestinya.",
	"Richard: Jadi urutannya harus sesuai dengan urutan kedatangan mereka?",
	"Jeanne: Tepat sekali.",
	"Jeanne: Jika kita melayani orang yang datang belakangan terlebih dahulu, antrean akan menjadi kacau dan para petualang bisa saja mengajukan protes.",
	"Jeanne: Prinsip FIFO inilah yang digunakan pada sistem antrean atau Queue.",
	"Jeanne: Dalam pekerjaanmu nanti, setiap petualang yang datang akan masuk ke dalam antrean. Tugasmu adalah melayani mereka berdasarkan urutan kedatangan.",
	"Richard: Aku mengerti sekarang. Jadi FIFO membantu menjaga keadilan dan keteraturan.",
	"Jeanne: Benar sekali.",
	"Jeanne: Namun, Richard, ada satu keadaan khusus yang perlu kamu ketahui.",
	"Richard: Keadaan khusus?",
	"Jeanne: Benar. Meskipun sebagian besar waktu kita menggunakan FIFO untuk menjaga keadilan dalam antrean, ada beberapa orang yang harus kita layani lebih dahulu meskipun mereka datang belakangan.",
	"Richard: Bukankah itu akan melanggar aturan FIFO?",
	"Jeanne: Secara teknis iya. Namun dalam dunia nyata, terkadang ada kondisi yang lebih penting daripada urutan kedatangan.",
	"Richard: Bisa beri aku contoh?",
	"Jeanne: Tentu.",
	"Jeanne: Misalkan ada lima petualang yang sedang mengantre. Tiba-tiba seorang bangsawan datang ke guild untuk meminta bantuan atau menyerahkan misi kerajaan.",
	"Jeanne: Dalam situasi seperti itu, kita harus mendahulukan bangsawan tersebut meskipun ia baru saja tiba.",
	"Richard: Jadi statusnya membuatnya lebih diprioritaskan dibanding orang lain?",
	"Jeanne: Tepat sekali.",
	"Jeanne: Sistem seperti ini disebut Priority Queue.",
	"Richard: Priority Queue?",
	"Jeanne: Ya. Pada Priority Queue, setiap orang atau data memiliki tingkat prioritas tertentu.",
	"Jeanne: Orang dengan prioritas lebih tinggi akan dilayani terlebih dahulu, meskipun ia tidak datang paling awal.",
	"Richard: Berarti urutan pelayanan tidak hanya ditentukan oleh waktu kedatangan?",
	"Jeanne: Benar.",
	"Jeanne: Pada guild ini, bangsawan memiliki prioritas lebih tinggi dibanding petualang biasa. Karena itu, jika seorang bangsawan datang, kita harus segera melayaninya terlebih dahulu.",
	"Richard: Aku mengerti sekarang.",
	"Richard: Jadi FIFO digunakan ketika semua orang memiliki prioritas yang sama, sedangkan Priority Queue digunakan ketika ada orang yang harus didahulukan berdasarkan tingkat kepentingannya.",
	"Jeanne: Tepat sekali.",
	"Jeanne: Sebagai resepsionis, tugasmu adalah menentukan apakah seseorang masuk ke antrean biasa atau antrean prioritas.",
	"Richard: Menarik juga. Ternyata mengelola antrean tidak sesederhana yang aku bayangkan.",
	"Jeanne: Itulah sebabnya pekerjaan ini membutuhkan ketelitian.",
	"Jeanne: Untuk saat ini, itu adalah aturan terpenting yang perlu kamu pahami saat bertugas di meja resepsionis.",
	"Jeanne: Tapi memahami teori saja tidak cukup.",
	"Jeanne: Cara terbaik untuk belajar adalah dengan langsung mempraktikkannya.",
	"Jeanne: Sekarang, cobalah layani para petualang yang datang menggunakan prinsip FIFO, tetapi jika ada bangsawan yang datang, kamu harus menerapkan Priority Queue.",
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
				get_tree().change_scene_to_file("res://Scenes/gamemodes/tutorial_fifo/tutorialfifo.tscn")

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
