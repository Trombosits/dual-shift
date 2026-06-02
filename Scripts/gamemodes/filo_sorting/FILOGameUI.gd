# FILOGameUI.gd
# Mengelola interaksi UI; tombol"an
extends CanvasLayer

@onready var game_manager: FILOGameManager = get_parent()
# Win Panel nodes
@onready var win_panel: Panel = $WinPanel
@onready var moves_value: Label = $WinPanel/VBoxContainer/StatsContainer/MovesBox/MovesValue
@onready var time_value: Label = $WinPanel/VBoxContainer/StatsContainer/TimeBox/TimeValue
@onready var next_btn: Button = $WinPanel/VBoxContainer/ButtonContainer/NextButton
@onready var replay_btn: Button = $WinPanel/VBoxContainer/ButtonContainer/ReplayButton
@onready var menu_btn: Button = $WinPanel/VBoxContainer/ButtonContainer/MainMenuButton

func _ready() -> void:
	next_btn.pressed.connect(_on_next_pressed)
	replay_btn.pressed.connect(_on_replay_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

# Dipanggil oleh GameManager saat menang
func show_win_screen(total_moves: int, elapsed_time: float) -> void:
	# Isi stats
	moves_value.text = str(total_moves)
	var minutes = (elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	time_value.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

	# Tampilkan panel dengan animasi scale-in
	win_panel.visible = true
	win_panel.scale = Vector2(0.5, 0.5)
	win_panel.modulate.a = 0.0

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(win_panel, "scale", Vector2(1.0, 1.0), 0.4)
	tween.parallel().tween_property(win_panel, "modulate:a", 1.0, 0.3)

func hide_win_screen() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(win_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.parallel().tween_property(win_panel, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): win_panel.visible = false)

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial/night_city.tscn")

func _on_replay_pressed() -> void:
	hide_win_screen()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/gamemodes/filo_sorting/FILOSortingGame.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")
