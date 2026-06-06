# FILOGameManager.gd
# Mengelola keseluruhan alur Gamemode FILO Sorting:
# - Setup level (buat rack + isi dengan potion acak)
# - Mendeteksi kondisi menang
# - Menghitung skor (moves & waktu)
# - Komunikasi dengan UI
extends Node2D
class_name FILOGameManager

# SIGNAL
signal game_won(total_moves: int, time_taken: float)
signal game_reset()
signal move_count_changed(new_count: int)

# DIFFICULTY
enum Difficulty {EASY, MEDIUM, HARD}

@export var current_difficulty : Difficulty = Difficulty.EASY

# DIFFICULTY SETTINGS
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

# NODE REFERENCES
@onready var difficulty_panel = $HUD/DifficultyPanel
@onready var easy_button = $HUD/DifficultyPanel/EasyButton
@onready var medium_button = $HUD/DifficultyPanel/MediumButton
@onready var hard_button = $HUD/DifficultyPanel/HardButton
@onready var drag_manager: DragManager = $HUD/DragManager
@onready var drag_layer: CanvasLayer = $DragLayer
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var sfx_pick: AudioStreamPlayer = $SFX_Pick
@onready var sfx_drop: AudioStreamPlayer = $SFX_Drop
@onready var moves_label: Label = $HUD/MovesLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var win_panel: Panel = $HUD/WinPanel
@onready var hud_layer: CanvasLayer = $HUD
@onready var win_sound = $HUD/WinSound
@onready var sparkle_burst = $DragLayer/SparkleBurst
@onready var confetti_particles = $ConfettiParticles
@onready var stars_label = $HUD/WinPanel/StarsLabel
@onready var score_label = $HUD/WinPanel/VBoxContainer/StatsContainer/ScoreBox/ScoreValue
@onready var ingame_score_label = $HUD/ScoreLabel
@onready var pause_panel = $HUD/PausePanel
@onready var continue_button = $HUD/PausePanel/BContainer1/Continue
@onready var restart_button = $HUD/PausePanel/BContainer2/Menu
@onready var back_button = $HUD/PausePanel/BContainer3/Restart
@onready var pause_button = $HUD/Panel/PauseButton
@onready var pause_button_panel = $HUD/Panel

# GAME STATE
var racks: Array[PotionRack] = []
var rack_y: float = 300.0
var total_moves: int = 0
var elapsed_time: float = 0.0
var game_active: bool = false
var final_score: int = 0
var is_paused := false

# Active config
var rack_count: int
var color_count: int
var rack_capacity: int
var empty_racks: int

# READY
func _ready() -> void:
	win_panel.visible = false
	pause_panel.visible = false
	difficulty_panel.visible = true
	game_active = false
	drag_manager.input_enabled = false
	total_moves = 0
	elapsed_time = 0.0
	_update_moves_display()
	_update_timer_display()
	_update_score_display()
	_connect_signals()

# PROCESS
func _process(delta: float) -> void:
	if game_active:
		elapsed_time += delta
		_update_timer_display()

# LOAD DIFFICULTY
func _load_difficulty_settings() -> void:
	var settings = difficulty_settings[current_difficulty]
	rack_count = settings["rack_count"]
	color_count = settings["color_count"]
	rack_capacity = settings["capacity"]
	empty_racks = settings["empty_racks"]
	match current_difficulty:
		Difficulty.EASY:   rack_y = 550.0
		Difficulty.MEDIUM: rack_y = 550.0
		Difficulty.HARD:   rack_y = 550.0

# GAME SETUP
func _setup_game() -> void:
	_clear_existing_racks()
	_create_racks()
	_generate_and_fill_potions()

	drag_manager.register_racks(racks)
	drag_manager.set_drag_layer(drag_layer)
	drag_manager.set_sfx(sfx_pick, sfx_drop)

	_update_moves_display()
	_update_timer_display()
	_update_score_display()

# CLEAR RACKS
func _clear_existing_racks() -> void:
	for rack in racks:
		if is_instance_valid(rack):
			rack.queue_free()
	racks.clear()

# CREATE RACKS
func _create_racks() -> void:
	var spacing := 180.0
	var total_width = (rack_count - 1) * spacing
	var start_x = -total_width / 2.0

	for i in range(rack_count):
		var rack := PotionRack.new()
		rack.rack_id = i
		rack.max_capacity = rack_capacity
		rack.current_difficulty = current_difficulty
		rack.position = Vector2(
			start_x + (i * spacing) + 600,
			rack_y
		)
		add_child(rack)
		racks.append(rack)

# GENERATE POTIONS
func _generate_and_fill_potions() -> void:
	var all_potions: Array = []
	# easy = 4 warna x 4 slot = 16 potion
	# medium = 5 warna x 5 slot = 25 potion
	# easy = 6 warna x 6 slot = 36 potion
	for type_idx in range(color_count):
		for j in range(rack_capacity):
			all_potions.append(type_idx)
	all_potions.shuffle()
	_distribute_potions(all_potions)

# DISTRIBUTE POTIONS
func _distribute_potions(potions: Array) -> void:

	# PILIH RACK KOSONG RANDOM
	var empty_indices = []
	while empty_indices.size() < empty_racks:
		var random_idx = randi() % rack_count
		if not empty_indices.has(random_idx):
			empty_indices.append(random_idx)

	# Rack yang boleh diisi
	var playable_racks = []
	for i in range(rack_count):
		if not empty_indices.has(i):
			playable_racks.append(i)

	# DISTRIBUTE POTIONS
	var rack_pointer := 0
	for potion_type in potions:
		var potion := Potion.new()
		potion.potion_type = potion_type as Potion.PotionType
		var current_rack = racks[playable_racks[rack_pointer]]
		while current_rack.is_full():
			rack_pointer = (rack_pointer + 1) % playable_racks.size()
			current_rack = racks[playable_racks[rack_pointer]]
		current_rack.push(potion)
		rack_pointer = (rack_pointer + 1) % playable_racks.size()

# SIGNALS
func _connect_signals() -> void:
	if not drag_manager.move_made.is_connected(_on_move_made):
		drag_manager.move_made.connect(_on_move_made)
	if not drag_manager.invalid_move_attempted.is_connected(_on_invalid_move):
		drag_manager.invalid_move_attempted.connect(_on_invalid_move)

# MOVE HANDLER
func _on_move_made(_from_rack: PotionRack, _to_rack: PotionRack, _potion: Potion) -> void:
	total_moves += 1
	_play_sparkle(_potion.global_position)
	move_count_changed.emit(total_moves)
	_update_score_display()
	_update_moves_display()
	if _check_win_condition():
		_trigger_win()

func _on_invalid_move(_from: PotionRack, _to: PotionRack) -> void:
	print("Invalid Move!")

# WIN CHECK
func _check_win_condition() -> bool:
	var sorted_racks := 0
	var non_empty_racks := 0
	for rack in racks:
		if not rack.is_empty():
			non_empty_racks += 1
			if rack.is_sorted():
				sorted_racks += 1
	var win := (sorted_racks == non_empty_racks and non_empty_racks == color_count)
	return win

# WIN
func _trigger_win() -> void:
	game_active = false
	drag_manager.input_enabled = false
	final_score = _calculate_score()
	win_sound.play()
	pause_button.visible = false
	pause_button_panel.visible = false
	pause_panel.visible = false
	confetti_particles.restart()
	confetti_particles.emitting = true
	var tween = create_tween()
	tween.tween_property(background_music, "volume_db", -80.0, 1.0)
	game_won.emit(total_moves, elapsed_time)
	_show_win_screen()

func _show_win_screen() -> void:
	hud_layer.show_win_screen(total_moves, elapsed_time)
	var stars = _calculate_star_rating()
	stars_label.text = "⭐".repeat(stars)
	score_label.text = "%d" % final_score

# UI
func _update_moves_display() -> void:
	moves_label.text = "Gerakan: %d" % total_moves

func _update_timer_display() -> void:
	var minutes = float(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var milliseconds = float((elapsed_time - int(elapsed_time)) * 100)
	timer_label.text = "Waktu: %02d:%02d:%02d" % [minutes,seconds,milliseconds]
	
func _update_score_display() -> void:
	var current_score = _calculate_score()
	ingame_score_label.text = "Skor: %d" % current_score

# RESET
func reset_game() -> void:
	background_music.volume_db = 0
	drag_manager.input_enabled = true
	total_moves = 0
	elapsed_time = 0.0
	game_active = false
	ingame_score_label.text = "Skor: 0"
	hud_layer.hide_win_screen()
	_load_difficulty_settings()
	_setup_game()
	pause_button.visible = true
	pause_button_panel.visible = true
	pause_panel.visible = false
	game_active = true
	game_reset.emit()
	if not background_music.playing:
		background_music.play()

# CHANGE DIFFICULTY
func set_difficulty(new_difficulty: Difficulty) -> void:
	current_difficulty = new_difficulty
	reset_game()

func _on_easy_button_pressed() -> void:
	_start_with_difficulty(Difficulty.EASY)

func _on_medium_button_pressed() -> void:
	_start_with_difficulty(Difficulty.MEDIUM)

func _on_hard_button_pressed() -> void:
	_start_with_difficulty(Difficulty.HARD)

func _update_difficulty_ui():
	easy_button.disabled = current_difficulty == Difficulty.EASY
	medium_button.disabled = current_difficulty == Difficulty.MEDIUM
	hard_button.disabled = current_difficulty == Difficulty.HARD
	
func _play_sparkle(pos: Vector2):
	sparkle_burst.global_position = pos
	sparkle_burst.restart()
	sparkle_burst.emitting = true
	
func _calculate_star_rating() -> int:
	if current_difficulty == Difficulty.EASY:
		if total_moves <= 17 and elapsed_time <= 60:
			return 3
		elif total_moves <= 25 and elapsed_time <= 120:
			return 2
		return 1
	elif current_difficulty == Difficulty.MEDIUM:
		if total_moves <= 25 and elapsed_time <= 90:
			return 3
		elif total_moves <= 35 and elapsed_time <= 180:
			return 2
		return 1
	else:
		if total_moves <= 35 and elapsed_time <= 150:
			return 3
		elif total_moves <= 50 and elapsed_time <= 300:
			return 2
		return 1
		
func _calculate_score() -> int:
	var base_score = 3000
	var move_penalty = total_moves * 25
	var time_penalty = int(elapsed_time) * 3
	var difficulty_bonus = 0
	match current_difficulty:
		Difficulty.EASY:
			difficulty_bonus = 0
		Difficulty.MEDIUM:
			difficulty_bonus = 500
		Difficulty.HARD:
			difficulty_bonus = 1000
	var star_bonus = _calculate_star_rating() * 500
	var score = (base_score - move_penalty - time_penalty + difficulty_bonus + star_bonus)
	return max(score, 0)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	is_paused = true
	get_tree().paused = true
	pause_panel.visible = true

func _resume_game():
	is_paused = false
	get_tree().paused = false
	pause_panel.visible = false

func _on_continue_pressed() -> void:
	_resume_game()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	pause_panel.visible = false
	drag_manager.input_enabled = true
	reset_game()

func _on_pause_button_pressed() -> void:
	if is_paused:
		_resume_game()
	else:
		_pause_game()

func _start_with_difficulty(new_difficulty: Difficulty) -> void:
	get_tree().paused = false
	is_paused = false
	current_difficulty = new_difficulty
	difficulty_panel.visible = false
	pause_panel.visible = false
	pause_button.visible = true
	pause_button_panel.visible = true
	total_moves = 0
	elapsed_time = 0.0
	game_active = false
	_load_difficulty_settings()
	_setup_game()
	drag_manager.input_enabled = true
	game_active = true
	if not background_music.playing:
		background_music.play()
