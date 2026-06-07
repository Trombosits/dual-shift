extends Control # Sesuaikan dengan tipe node root kamu (Control / Node2D)

# Hubungkan ke label teks yang baru saja kamu buat di dalam Panel2
@onready var points_label = $Panel2/PointsLabel 

func _ready():
	# Tampilkan poin saat layar skill tree pertama kali dibuka
	update_points_display()

func update_points_display():
	if is_instance_valid(points_label):
		# Ambil nilai terbaru dari GlobalManager
		points_label.text = "Poin Tersedia: " + str(GlobalManager.total_skill_points)
