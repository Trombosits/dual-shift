extends Node2D

@onready var _spawner = $EnemySpawner

@onready var _damage_line = $damageLine
@onready var _player = $player

# ---  UI GAME   ---
@onready var _life_label = $HUD/Life
@onready var _score_label = $HUD/Score
@onready var _wave_label = $HUD/Wave
@onready var _win_panel = $HUD/WinPanel
#@onready var _highscore_label = $HUD/WinPanel/Highscore
@onready var _next_button = $"HUD/WinPanel/Next-Button" 
# ------------------

@export var max_life: int = 3

# File path untuk menyimpan highscore secara lokal
#const SAVE_PATH = "user://highscore.save"

var score: int = 0:
	set(value):
		score = value
		_score_label.text = "Score : " + str(score)

var life: int = 3:
	set(value):
		life = value
		_life_label.text = "Life : " + str(life)
		if life <= 0 and not game_over_displayed and not win_displayed:
			trigger_game_over()

# --- STATE TRACKING BARU ---
var game_over_displayed: bool = false
var win_displayed: bool = false
var current_wave: int = 0
var wave_3_enemy_spawned: bool = false
# ----------------------------

func _ready():
	# Pastikan panel Win/Lose disembunyikan saat game dimulai
	_win_panel.hide()
	
	# Hubungkan sinyal tombol Next ke fungsi
	_next_button.pressed.connect(_on_next_button_pressed)
	
	life = max_life
	score = 0
	_damage_line.line_breached.connect(_on_damage_line_breached)
	
	# Hubungkan sinyal wave untuk mencatat wave yang sedang aktif saat ini
	_spawner.wave_started.connect(func(wave_num): 
		current_wave = wave_num
		_wave_label.text = "Wave: " + str(wave_num)
	)
	_spawner.wave_break_started.connect(func(duration): _wave_label.text = "Get Ready!")


func _input(event):
	if game_over_displayed or win_displayed: return
	
	if event is InputEventKey and event.pressed and len(_spawner.enemies) > 0:
		var key_input = event.as_text()
		
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
					_player.play_hurt() 
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
				_player.play_attack()
				
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
				_player.play_hurt() 
				print("Wrong input! Character mismatch. Life decreased.")


func _physics_process(_delta):
	if game_over_displayed or win_displayed: return
	
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
	if current_wave == 3:
		if _spawner.enemies.size() > 0:
			# Sinyalkan bahwa musuh wave 3 sudah mulai bermunculan di layar
			wave_3_enemy_spawned = true
		elif wave_3_enemy_spawned and _spawner.enemies.size() == 0:
			# Jika musuh sudah pernah muncul DAN sekarang jumlahnya kembali 0, artinya KAMU MENANG!
			trigger_win()


func _on_damage_line_breached():
	if game_over_displayed or win_displayed: return 
	
	life -= 1
	_player.play_hurt()
	
	if len(_spawner.enemies) > 0:
		var enemy = _spawner.enemies[0]
		if is_instance_valid(enemy):
			if enemy.has_method("play_die"):
				enemy.play_die()
			else:
				enemy.queue_free()
		_spawner.enemies.pop_front()


# --- PATH KONDISI KALAH (LOSE) ---
func trigger_game_over():
	game_over_displayed = true
	AudioManager.play_gameOver()
	
	# Bekukan musuh instan
	freeze_all_entities()

	await get_tree().create_timer(1.75).timeout
	if is_instance_valid(_player):
		_player.play_death()
		
	await get_tree().create_timer(1.75).timeout
	if is_instance_valid(_player):
		_player.process_mode = PROCESS_MODE_DISABLED
	
	# Tampilkan panel dengan text Game Over
	show_end_panel(false)


# --- PATH KONDISI MENANG (WIN) ---
func trigger_win():
	win_displayed = true
	# Opsional: AudioManager.play_victory() jika ada sound efek menang
	
	# Bekukan musuh dan player instan (Pemain tidak mati karena menang)
	freeze_all_entities()
	if is_instance_valid(_player):
		_player.process_mode = PROCESS_MODE_DISABLED
		
	# Tampilkan panel dengan text Victory
	show_end_panel(true)


# --- FUNGSI BANTUAN OPTIMASI (HELPERS) ---
func freeze_all_entities():
	if is_instance_valid(_spawner):
		_spawner.process_mode = PROCESS_MODE_DISABLED
		for enemy in _spawner.enemies:
			if is_instance_valid(enemy):
				enemy.process_mode = PROCESS_MODE_DISABLED

func show_end_panel(is_victory: bool):
	#var highscore = load_highscore()
	#
	#if score > highscore:
		#highscore = score
		#save_highscore(highscore)
	
	# Mengubah isi text komponen utama berdasarkan status akhir game
	if is_victory:
		$HUD/WinPanel/Win.text = "VICTORY!\nScore: " + str(score)
	else:
		$HUD/WinPanel/Win.text = "GAME OVER\n"
		
	#_highscore_label.text = "Highscore: " + str(highscore)
	_win_panel.show()


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")


#func load_highscore() -> int:
	#if FileAccess.file_exists(SAVE_PATH):
		#var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		#var saved_score = file.get_32()
		#file.close()
		#return saved_score
	#return 0

#func save_highscore(new_highscore: int):
	#var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	#file.store_32(new_highscore)
	#file.close()
