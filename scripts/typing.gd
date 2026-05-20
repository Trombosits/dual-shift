extends Node2D

@onready var _spawner = $EnemySpawner
@onready var _life_label = $CanvasLayer/Life
@onready var _score_label = $CanvasLayer/Score
@onready var _wave_label = $CanvasLayer/Wave

@onready var _damage_line = $damageLine
@onready var _player = $player

@export var max_life: int = 3

var score: int = 0:
	set(value):
		score = value
		_score_label.text = "Score : " + str(score)

var life: int = 3:
	set(value):
		life = value
		_life_label.text = "Life : " + str(life)
		if life <= 0 and not game_over_displayed:
			trigger_game_over()

var game_over_displayed: bool = false

func _ready():
	life = max_life
	score = 0
	_damage_line.line_breached.connect(_on_damage_line_breached)
	_spawner.wave_started.connect(func(wave_num): _wave_label.text = "Wave: " + str(wave_num))
	_spawner.wave_break_started.connect(func(duration): _wave_label.text = "Get Ready!")

# ==========================================
# FUNGSI FILTER PRIORITY ORDER (PENTING)
# ==========================================
func _get_current_target_index() -> int:
	# 1. Cari apakah ada musuh yang bertipe BOSS di dalam daftar screen saat ini
	for i in range(_spawner.enemies.size()):
		var enemy = _spawner.enemies[i]
		if is_instance_valid(enemy) and enemy.get("is_boss") == true:
			return i # Jika ada Boss, paksa pemain mengincar indeks Boss ini!
			
	# 2. Jika tidak ada boss, gunakan penargetan normal bawaan game kamu
	if _spawner.enemy_index >= _spawner.enemies.size():
		_spawner.enemy_index = 0
	return _spawner.enemy_index


func _input(event):
	if game_over_displayed: return
	
	if event is InputEventKey and event.pressed and len(_spawner.enemies) > 0:
		var key_input = event.as_text()
		
		# Gunakan fungsi filter untuk mengambil index target terkuat (Boss dahulu)
		var active_index = _get_current_target_index()
		var current_enemy = _spawner.enemies[active_index]
		
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
			else:
				life -= 1
				_player.play_hurt() 
				print("Wrong input! Life decreased.")

func _physics_process(_delta):
	if game_over_displayed: return
	
	if len(_spawner.enemies) > 0:
		# Gunakan fungsi filter untuk pengecekan kematian musuh
		var active_index = _get_current_target_index()
		var current_enemy = _spawner.enemies[active_index]
		
		if is_instance_valid(current_enemy) and len(current_enemy.GENERATED_CHARS) == 0:
			
			if current_enemy.has_method("play_die"):
				current_enemy.play_die()
			else:
				current_enemy.queue_free()
				
			_spawner.enemies.pop_at(active_index)
			
			# Berikan skor lebih tinggi jika berhasil membunuh Boss
			if current_enemy.get("is_boss") == true:
				score += 1000
			else:
				score += 250
				
			if _spawner.enemy_index >= len(_spawner.enemies):
				_spawner.enemy_index = 0

func _on_damage_line_breached():
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

func trigger_game_over():
	game_over_displayed = true
	AudioManager.play_gameOver()
	
	await get_tree().create_timer(1.75).timeout
	_player.play_death()
	await get_tree().create_timer(0.75).timeout
