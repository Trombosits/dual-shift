extends Control # Sesuaikan dengan tipe node root kamu (Control / Node2D)

# Hubungkan ke label teks yang baru saja kamu buat di dalam Panel2
@onready var points_label = $PointsLabel
@onready var all : Panel = $All
@onready var fifo1 : Panel = $Fifo1
@onready var fifo2 : Panel = $Fifo2
@onready var filo1 : Panel = $Filo1
@onready var filo2 : Panel = $Filo2
@onready var typing1 : Panel = $Typing1
@onready var typing2 : Panel = $Typing2
@onready var back = $Back

func _ready():
	# Tampilkan poin saat layar skill tree pertama kali dibuka
	update_points_display()

func update_points_display():
	if is_instance_valid(points_label):
		# Ambil nilai terbaru dari GlobalManager
		points_label.text = "Poin Tersedia: " + str(GlobalManager.total_skill_points)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")

func _on_score_all_mouse_entered() -> void:
	all.visible = true
func _on_score_all_mouse_exited() -> void:
	all.visible = false

func _on_score_fifo_1_mouse_entered() -> void:
	fifo1.visible = true
func _on_score_fifo_1_mouse_exited() -> void:
	fifo1.visible = false

func _on_score_fifo_2_mouse_entered() -> void:
	fifo2.visible = true
func _on_score_fifo_2_mouse_exited() -> void:
	fifo2.visible = false

func _on_score_filo_1_mouse_entered() -> void:
	filo1.visible = true
func _on_score_filo_1_mouse_exited() -> void:
	filo1.visible = false

func _on_score_filo_2_mouse_entered() -> void:
	filo2.visible = true
func _on_score_filo_2_mouse_exited() -> void:
	filo2.visible = false

func _on_score_typing_1_mouse_entered() -> void:
	typing1.visible = true
func _on_score_typing_1_mouse_exited() -> void:
	typing1.visible = false

func _on_score_typing_2_mouse_entered() -> void:
	typing2.visible = true
func _on_score_typing_2_mouse_exited() -> void:
	typing2.visible = false
