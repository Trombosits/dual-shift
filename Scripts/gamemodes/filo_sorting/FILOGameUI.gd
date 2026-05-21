# FILOGameUI.gd
# Mengelola interaksi UI: tombol reset, tombol next, dll.
extends CanvasLayer

@onready var game_manager: FILOGameManager = get_parent()

func _ready() -> void:
	# Sambungkan tombol Next (di WinPanel) jika ada
	var next_btn = get_node_or_null("WinPanel/NextButton")
	if next_btn:
		next_btn.pressed.connect(_on_next_pressed)

	var reset_btn = get_node_or_null("ResetButton")
	if reset_btn:
		reset_btn.pressed.connect(_on_reset_pressed)

func _on_next_pressed() -> void:
	# TODO: Pindah ke Gamemode 3 (Typing SIFO/FIFO)
	# get_tree().change_scene_to_file("res://scenes/gamemodes/typing/TypingGame.tscn")
	print("[UI] Lanjut ke gamemode berikutnya")

func _on_reset_pressed() -> void:
	if game_manager:
		game_manager.reset_game()
