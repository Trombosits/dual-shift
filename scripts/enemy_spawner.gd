extends Node2D

@onready var enemy_scene = preload("res://scenes/enemy_mushroom.tscn") 
@onready var boss_scene = preload("res://scenes/enemy_boss.tscn") 

var enemies = []
var enemy_index = 0
var is_gameover = false

# ==========================================
# VARIABEL SISTEM WAVE & BOSS
# ==========================================
var current_wave: int = 1
var enemies_to_spawn: int = 3          
var enemies_spawned_this_wave: int = 0  
var boss_spawned_this_wave: bool = false 

var enemy_cooldown: float = 2.0        
var spawn_timer: float = 0.0

var wave_break_duration: float = 4.0   
var break_timer: float = 2.0           
var is_in_break: bool = true           

signal wave_started(wave_number)
signal wave_break_started(duration)

func _ready():
	spawn_timer = enemy_cooldown
	emit_signal("wave_break_started", break_timer)

func _process(delta):	
	if is_gameover:
		_clear_all_enemies()
		return

	if is_in_break:
		_handle_wave_break(delta)
	else:
		_handle_enemy_spawning(delta)
		_check_wave_completion()

func _handle_wave_break(delta):
	break_timer -= delta
	if break_timer <= 0:
		is_in_break = false
		enemies_spawned_this_wave = 0
		boss_spawned_this_wave = false 
		
		enemies_to_spawn = 3 + (current_wave - 1) * 2
		
		if current_wave % 3 == 0:
			enemies_to_spawn += 1
		
		enemy_cooldown = max(0.6, 2.0 - (current_wave * 0.15))
		
		# MEMBUAT BOSS MUNCUL PERTAMA: Set timer ke 0 agar langsung spawn saat wave mulai
		spawn_timer = 0 
		
		emit_signal("wave_started", current_wave)
		print("WAVE ", current_wave, " DIMULAI! Total target: ", enemies_to_spawn)

func _handle_enemy_spawning(delta):
	if enemies_spawned_this_wave >= enemies_to_spawn:
		return 

	spawn_timer -= delta
	if spawn_timer <= 0:
		_spawn_enemy()
		spawn_timer = enemy_cooldown

func _spawn_enemy():
	# JIKA WAVE KELIPATAN 3 & BOSS BELUM SPAWN -> PASTI SPAWN BOSS DULUAN
	if current_wave % 3 == 0 and not boss_spawned_this_wave:
		var boss_instance = boss_scene.instantiate()
		var y = randi() % 401 - 200
		boss_instance.position = Vector2(600, y)
		
		enemies.append(boss_instance)
		add_child(boss_instance)
		boss_spawned_this_wave = true
		enemies_spawned_this_wave += 1
		print("!!! BOSS MUNCUL PERTAMA !!!")
		return 
		
	# Spawn musuh biasa (Kroco) setelah boss muncul
	var enemy_instance = enemy_scene.instantiate() 
	var y = randi() % 401 - 200 
	enemy_instance.position = Vector2(600, y) 
	
	if current_wave <= 2:
		enemy_instance.difficulty = 1 
	elif current_wave <= 4:
		enemy_instance.difficulty = 2 
	else:
		enemy_instance.difficulty = 3 
		
	enemies.append(enemy_instance)
	add_child(enemy_instance)
	enemies_spawned_this_wave += 1

# FUNGSI CEK KEBERADAAN BOSS (Akan dibaca oleh musuh biasa)
func is_boss_present() -> bool:
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.get("is_boss") == true:
			return true
	return false

func _check_wave_completion():
	if enemies_spawned_this_wave >= enemies_to_spawn and enemies.is_empty():
		_start_next_wave_break()

func _start_next_wave_break():
	is_in_break = true
	current_wave += 1
	break_timer = wave_break_duration
	emit_signal("wave_break_started", wave_break_duration)
	print("Wave selesai! Bersiap untuk Wave ", current_wave)

func _clear_all_enemies():
	if len(enemies) > 0:
		for i in enemies:
			if is_instance_valid(i):
				i.queue_free()
		enemies = []
