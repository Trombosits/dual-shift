extends Node2D

@onready var _spawner = $EnemySpawner

@onready var _damage_line = $damageLine
@onready var _player = $player

# ---   UI GAME   ---
@onready var _life_label = $HUD/HeartPanel/Life
@onready var _score_label = $HUD/ScorePanel/Score
@onready var _wave_label = $HUD/WavePanel/Wave


@onready var _lose_panel = $HUD/LosePanel
@onready var _highscore_label = $HUD/LosePanel/Highscore
@onready var _next_button = $"HUD/LosePanel/Next-Button" 


@onready var _pause_panel = $HUD/PausePanel
@onready var _continue_button = $HUD/PausePanel/BContainer1/Continue
@onready var _menu_button = $HUD/PausePanel/BContainer2/Menu
# ------------------

@export var max_life: int = 3

var score: int = 0:
	set(value):
		score = value
		if is_instance_valid(_score_label):
			_score_label.text = "Score : " + str(score)

var life: int = 3:
	set(value):
		life = value
		if is_instance_valid(_life_label):
			_life_label.text = "Life : " + str(life)
		if life <= 0 and not game_over_displayed and not win_displayed:
			trigger_game_over()

# --- STATE TRACKING ---
var game_over_displayed: bool = false
var win_displayed: bool = false
var current_wave: int = 0
var wave_3_enemy_spawned: bool = false
# ----------------------------

func _ready():
	# Sembunyikan semua panel UI di awal game
	if is_instance_valid(_lose_panel): _lose_panel.hide()
	if is_instance_valid(_pause_panel): _pause_panel.hide()
	
	# Hubungkan sinyal tombol Lose Panel
	if is_instance_valid(_next_button):
		_next_button.pressed.connect(_on_next_button_pressed)
	
	# Hubungkan sinyal tombol Pause Panel
	if is_instance_valid(_continue_button):
		_continue_button.pressed.connect(_on_continue_button_pressed)
	if is_instance_valid(_menu_button):
		_menu_button.pressed.connect(_on_menu_button_pressed)
	
	life = max_life
	score = 0
	
	if is_instance_valid(_damage_line):
		_damage_line.line_breached.connect(_on_damage_line_breached)
	
	if is_instance_valid(_spawner):
		_spawner.wave_started.connect(func(wave_num): 
			current_wave = wave_num
			if is_instance_valid(_wave_label):
				_wave_label.text = "Wave: " + str(wave_num)
		)
		_spawner.wave_break_started.connect(func(duration): 
			if is_instance_valid(_wave_label):
				_wave_label.text = "Get Ready!"
		)


func _input(event):
	# Fitur global tombol ESCAPE untuk Pause / Unpause
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if not game_over_displayed and not win_displayed:
			if get_tree().paused:
				_on_continue_button_pressed() # Lanjut jika sedang pause
			else:
				trigger_pause() # Jeda jika sedang main
			return

	# Jangan proses ketikan huruf jika game selesai atau sedang dipause
	if game_over_displayed or win_displayed or get_tree().paused: return
	
	if event is InputEventKey and event.pressed:
		var key_input = event.as_text()
		var excluded_key = ["Escape", "Space", "Enter", "Backspace", "Return", "Tab"]
		
		if key_input in excluded_key:
			return
	
		if is_instance_valid(_spawner) and len(_spawner.enemies) > 0:
			var current_enemy = null
			var active_index = -1
		
			# 1. MODE PRIORITY ORDER: Jika ada BOSS
			for i in range(_spawner.enemies.size()):
				var enemy = _spawner.enemies[i]
				if is_instance_valid(enemy) and enemy.get("is_boss") == true:
					active_index = i
					current_enemy = enemy
					break
			
			# 2. MODE SEARCH IN RANDOM OUTPUT: Cari musuh biasa
			if current_enemy == null:
				# A. Cek yang SEDANG diketik
				for i in range(_spawner.enemies.size()):
					var enemy = _spawner.enemies[i]
					if is_instance_valid(enemy) and enemy.get("char_index") != null and enemy.char_index > 0:
						if len(enemy.GENERATED_CHARS) > 0 and enemy.GENERATED_CHARS[0].length() > 0:
							active_index = i
							current_enemy = enemy
							break
				
				# B. Cek huruf pertama cocok
				if current_enemy == null:
					var matching_indices = []
					for i in range(_spawner.enemies.size()):
						var enemy = _spawner.enemies[i]
						if is_instance_valid(enemy) and len(enemy.GENERATED_CHARS) > 0:
							var current_word = enemy.GENERATED_CHARS[0]
							if current_word.length() > 0 and current_word[0] == key_input:
								matching_indices.append(i)
					
					if matching_indices.size() > 0:
						active_index = matching_indices[randi() % matching_indices.size()]
						current_enemy = _spawner.enemies[active_index]
					else:
						life -= 1
						safe_play_player_animation("play_hurt")
						print("Wrong input! No matching enemy found. Life decreased.")
						return

			# 3. PROSES KETIKAN
			if not is_instance_valid(current_enemy): return
			
			if len(current_enemy.GENERATED_CHARS) > 0:
				var current_word = current_enemy.GENERATED_CHARS[0]
				if current_word.length() <= 0: return

				var current_char = current_word[0]
				if key_input == current_char:
					AudioManager.play_key() 
					safe_play_player_animation("play_attack")
					
					if current_enemy.has_method("play_hit"):
						current_enemy.play_hit()
					
					current_word = current_word.substr(1)
					current_enemy.char_index += 1
					current_enemy.GENERATED_CHARS[0] = current_word
					
					if current_word == "":
						current_enemy.GENERATED_CHARS.pop_front()
						current_enemy.char_index = 0
				else:
					life -= 1
					safe_play_player_animation("play_hurt")
					print("Wrong input! Character mismatch. Life decreased.")


func _physics_process(_delta):
	if game_over_displayed or win_displayed: return
	
	if is_instance_valid(_spawner):
		for i in range(_spawner.enemies.size() - 1, -1, -1):
			var current_enemy = _spawner.enemies[i]
			
			if is_instance_valid(current_enemy) and len(current_enemy.GENERATED_CHARS) == 0:
				if current_enemy.has_method("play_die"):
					current_enemy.play_die()
				else:
					current_enemy.queue_free()
					
				_spawner.enemies.pop_at(i)
				
				if current_enemy.get("is_boss") == true:
					score += 1000
				else:
					score += 250
					
				if _spawner.enemy_index >= len(_spawner.enemies):
					_spawner.enemy_index = 0

	# === LOGIKA DETEKSI MENANG (SELESAI WAVE 3) ===
	if current_wave == 3 and is_instance_valid(_spawner):
		if _spawner.enemies.size() > 0:
			wave_3_enemy_spawned = true
		elif wave_3_enemy_spawned and _spawner.enemies.size() == 0:
			trigger_win()


func _on_damage_line_breached():
	if game_over_displayed or win_displayed: return 
	
	life -= 1
	safe_play_player_animation("play_hurt")
	
	if is_instance_valid(_spawner) and len(_spawner.enemies) > 0:
		var enemy = _spawner.enemies[0]
		if is_instance_valid(enemy):
			if enemy.has_method("play_die"):
				enemy.play_die()
			else:
				enemy.queue_free()
		_spawner.enemies.pop_front()


# --- PATH LOGIKA PAUSE MENU ---
func trigger_pause():
	if is_instance_valid(_pause_panel):
		_pause_panel.show()
	get_tree().paused = true

func _on_continue_button_pressed():
	if is_instance_valid(_pause_panel):
		_pause_panel.hide()
	get_tree().paused = false

func _on_menu_button_pressed():
	get_tree().paused = false # Lepaskan status freeze sebelum pindah scene
	get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")


# --- PATH KONDISI KALAH (LOSE) ---
func trigger_game_over():
	game_over_displayed = true
	AudioManager.play_gameOver()
	freeze_all_entities()
	
	GlobalManager.total_skill_points += score

	await get_tree().create_timer(1.75).timeout
	safe_play_player_animation("play_death")
		
	await get_tree().create_timer(1.75).timeout
	if is_instance_valid(_player):
		_player.process_mode = PROCESS_MODE_DISABLED
	
	show_end_panel(false)


# --- PATH KONDISI MENANG (WIN) ---
func trigger_win():
	win_displayed = true
	freeze_all_entities()
	if is_instance_valid(_player):
		_player.process_mode = PROCESS_MODE_DISABLED
		
	GlobalManager.total_skill_points += score
		
	show_end_panel(true)


# --- FUNGSI BANTUAN OPTIMASI (HELPERS) ---
func freeze_all_entities():
	if is_instance_valid(_spawner):
		_spawner.process_mode = PROCESS_MODE_DISABLED
		for enemy in _spawner.enemies:
			if is_instance_valid(enemy):
				enemy.process_mode = PROCESS_MODE_DISABLED

func show_end_panel(is_victory: bool):
	if is_instance_valid(_lose_panel):
		var label_target = _lose_panel.get_node_or_null("Lose")
		if is_instance_valid(label_target):
			if is_victory:
				label_target.text = "VICTORY!\nScore: " + str(score)
			else:
				label_target.text = "GAME OVER\n"
		_lose_panel.show()

func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")

# Fungsi pengaman agar game tidak crash saat memanggil fungsi animasi player
func safe_play_player_animation(method_name: String):
	if is_instance_valid(_player) and _player.has_method(method_name):
		_player.call(method_name)
