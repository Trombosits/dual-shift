# FILOGameManager.gd
# Mengelola keseluruhan alur Gamemode FILO Sorting:
# - Setup level (buat rack + isi dengan potion acak)
# - Mendeteksi kondisi menang
# - Menghitung skor (moves & waktu)
# - Komunikasi dengan UI
extends Node2D
class_name FILOGameManager

# =========================================================
# SIGNAL
# =========================================================

signal game_won(total_moves: int, time_taken: float)
signal game_reset()
signal move_count_changed(new_count: int)

# =========================================================
# DIFFICULTY
# =========================================================

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

@export var current_difficulty : Difficulty = Difficulty.EASY

# =========================================================
# DIFFICULTY SETTINGS
# =========================================================

var difficulty_settings = {
	Difficulty.EASY: {
		"rack_count": 4,
		"color_count": 3,
		"capacity": 4,
		"empty_racks": 1
	},

	Difficulty.MEDIUM: {
		"rack_count": 5,
		"color_count": 4,
		"capacity": 5,
		"empty_racks": 1
	},

	Difficulty.HARD: {
		"rack_count": 6,
		"color_count": 5,
		"capacity": 6,
		"empty_racks": 1
	}
}

# =========================================================
# NODE REFERENCES
# =========================================================
@onready var difficulty_panel = $HUD/DifficultyPanel
@onready var easy_button = $HUD/DifficultyPanel/EasyButton
@onready var medium_button = $HUD/DifficultyPanel/MediumButton
@onready var hard_button = $HUD/DifficultyPanel/HardButton

@onready var drag_manager: DragManager = $HUD/DragManager
@onready var drag_layer: CanvasLayer = $DragLayer

@onready var moves_label: Label = $HUD/MovesLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var win_panel: Panel = $HUD/WinPanel

# =========================================================
# GAME STATE
# =========================================================

var racks: Array[PotionRack] = []
var rack_y = 300 - ((rack_capacity - 4) * 70)
var total_moves: int = 0
var elapsed_time: float = 0.0
var game_active: bool = false

# Active config
var rack_count: int
var color_count: int
var rack_capacity: int
var empty_racks: int

# =========================================================
# READY
# =========================================================

func _ready() -> void:
	win_panel.visible = false

	_load_difficulty_settings()

	_connect_signals()

	game_active = true

	print("=== FILO SORTING START ===")
	print("Difficulty:", Difficulty.keys()[current_difficulty])

# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:
	if game_active:
		elapsed_time += delta
		_update_timer_display()

# =========================================================
# LOAD DIFFICULTY
# =========================================================

func _load_difficulty_settings() -> void:
	var settings = difficulty_settings[current_difficulty]

	rack_count = settings["rack_count"]
	color_count = settings["color_count"]
	rack_capacity = settings["capacity"]
	empty_racks = settings["empty_racks"]

# =========================================================
# GAME SETUP
# =========================================================

func _setup_game() -> void:
	_clear_existing_racks()

	_create_racks()

	_generate_and_fill_potions()

	drag_manager.register_racks(racks)
	drag_manager.set_drag_layer(drag_layer)

	_update_moves_display()
	_update_timer_display()

	print("[SETUP COMPLETE]")
	_debug_print_state()

# =========================================================
# CLEAR RACKS
# =========================================================

func _clear_existing_racks() -> void:
	for rack in racks:
		if is_instance_valid(rack):
			rack.queue_free()

	racks.clear()

# =========================================================
# CREATE RACKS
# =========================================================

func _create_racks() -> void:
	var spacing := 180.0

	var total_width = (rack_count - 1) * spacing
	var start_x = -total_width / 2.0

	for i in range(rack_count):

		var rack := PotionRack.new()

		rack.rack_id = i
		rack.max_capacity = rack_capacity
		
		rack.position = Vector2(
			start_x + (i * spacing) + 600,
			rack_y
		)

		add_child(rack)

		racks.append(rack)

	print("Created Racks:", racks.size())

# =========================================================
# GENERATE POTIONS
# =========================================================

func _generate_and_fill_potions() -> void:

	var all_potions: Array = []

	# contoh:
	# easy = 3 warna x 4 slot = 12 potion
	for type_idx in range(color_count):

		for j in range(rack_capacity):

			all_potions.append(type_idx)

	all_potions.shuffle()

	_distribute_potions(all_potions)

# =========================================================
# DISTRIBUTE POTIONS
# =========================================================

func _distribute_potions(potions: Array) -> void:

	var playable_racks = rack_count - empty_racks

	var rack_idx := 0

	for potion_type in potions:

		var potion := Potion.new()

		potion.potion_type = potion_type as Potion.PotionType

		while racks[rack_idx].is_full():
			rack_idx = (rack_idx + 1) % playable_racks

		racks[rack_idx].push(potion)

		rack_idx = (rack_idx + 1) % playable_racks

# =========================================================
# SIGNALS
# =========================================================

func _connect_signals() -> void:

	if not drag_manager.move_made.is_connected(_on_move_made):
		drag_manager.move_made.connect(_on_move_made)

	if not drag_manager.invalid_move_attempted.is_connected(_on_invalid_move):
		drag_manager.invalid_move_attempted.connect(_on_invalid_move)

# =========================================================
# MOVE HANDLER
# =========================================================

func _on_move_made(
	_from_rack: PotionRack,
	_to_rack: PotionRack,
	_potion: Potion
) -> void:

	total_moves += 1

	move_count_changed.emit(total_moves)

	_update_moves_display()

	if _check_win_condition():
		_trigger_win()

func _on_invalid_move(
	_from: PotionRack,
	_to: PotionRack
) -> void:

	print("Invalid Move!")

# =========================================================
# WIN CHECK
# =========================================================

func _check_win_condition() -> bool:

	var sorted_racks := 0
	var non_empty_racks := 0

	for rack in racks:

		if not rack.is_empty():

			non_empty_racks += 1

			if rack.is_sorted():
				sorted_racks += 1

	var win := (
		sorted_racks == non_empty_racks
		and non_empty_racks == color_count
	)

	return win

# =========================================================
# WIN
# =========================================================

func _trigger_win() -> void:

	game_active = false

	game_won.emit(total_moves, elapsed_time)

	print("GAME WIN!")

	_show_win_screen()

func _show_win_screen() -> void:

	win_panel.visible = true

	var win_label = win_panel.get_node_or_null("WinLabel")

	if win_label:

		win_label.text = (
			"🎉 SELESAI!\n"
			+ "Difficulty: "
			+ Difficulty.keys()[current_difficulty]
			+ "\nMoves: "
			+ str(total_moves)
			+ "\nTime: "
			+ str(snapped(elapsed_time, 0.1))
		)

# =========================================================
# UI
# =========================================================

func _update_moves_display() -> void:

	moves_label.text = "Moves: %d" % total_moves

func _update_timer_display() -> void:

	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60

	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

# =========================================================
# RESET
# =========================================================

func reset_game() -> void:

	total_moves = 0
	elapsed_time = 0.0

	game_active = false

	win_panel.visible = false

	_load_difficulty_settings()

	_setup_game()

	game_active = true

	game_reset.emit()

# =========================================================
# CHANGE DIFFICULTY
# =========================================================

func set_difficulty(new_difficulty: Difficulty) -> void:

	current_difficulty = new_difficulty

	reset_game()

# =========================================================
# DEBUG
# =========================================================

func _debug_print_state() -> void:

	print("==== RACK STATE ====")

	for rack in racks:

		var types = rack.get_stack_types().map(
			func(t):
				return Potion.POTION_NAMES[t]
		)

		print(
			"Rack %d [%d/%d] -> %s"
			% [
				rack.rack_id,
				rack.get_size(),
				rack.max_capacity,
				str(types)
			]
		)

	print("====================")


func _on_easy_button_pressed() -> void:
	current_difficulty = Difficulty.EASY
	_load_difficulty_settings()
	_setup_game()
	difficulty_panel.visible = false
	game_active = true


func _on_medium_button_pressed() -> void:
	current_difficulty = Difficulty.MEDIUM
	_load_difficulty_settings()
	_setup_game()
	difficulty_panel.visible = false
	game_active = true

func _on_hard_button_pressed() -> void:
	current_difficulty = Difficulty.HARD
	_load_difficulty_settings()
	_setup_game()
	difficulty_panel.visible = false
	game_active = true

func _update_difficulty_ui():
	easy_button.disabled = current_difficulty == Difficulty.EASY
	medium_button.disabled = current_difficulty == Difficulty.MEDIUM
	hard_button.disabled = current_difficulty == Difficulty.HARD
