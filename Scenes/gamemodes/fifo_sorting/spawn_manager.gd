extends Node2D

@export var priority_npc_scene : PackedScene
@export var npc_scene : PackedScene

@onready var heart1 = $"../UI/HPContainer/Heart1"
@onready var heart2 = $"../UI/HPContainer/Heart2"
@onready var heart3 = $"../UI/HPContainer/Heart3"

@onready var game_over_panel = $"../UI/GameOverPanel"
@onready var pause_panel = $"../UI/PausePanel"

@onready var score_text = $"../UI/ScorePanel/ScoreText"
@onready var wave_text = $"../UI/WavePanel/WaveText"
@onready var timer_text = $"../UI/TimerPanel/TimerText"
@onready var start_wave_panel = $"../UI/StartWavePanel"
@onready var start_wave_text = $"../UI/StartWavePanel/StartWaveText"
@onready var final_score_text = $"../UI/GameOverPanel/VBoxContainer/PanelContainer2/FinalScoreText"

@onready var bgm = $"../BGMPlayer"
@onready var click_sfx = $"../ClickSfx"
@onready var wrong_sfx = $"../WrongSfx"
@onready var game_over_sfx = $"../GameOverSfx"
@onready var priority_wrong_sfx = $"../PriorityWrongSfx"

var current_wave = 1

var wave_timer = 30.0
var current_time = 30.0

var next_wave_score = 250

var game_started = false
var between_wave = false

var queue = []

var hp = 3
var score = 0

var is_paused = false

var variants = ["red", "green", "blue"]

var priority_chance = 5

var queue_positions = [
	Vector2(144, 100),
	Vector2(144, 120),
	Vector2(144, 140),
	Vector2(144, 160),
	Vector2(144, 180),
	Vector2(144, 200),
	Vector2(144, 220),
	Vector2(144, 240),
	Vector2(144, 260),
	Vector2(144, 280),
]

func _ready():

	randomize()

	update_hp_ui()
	update_score_ui()

	update_wave_ui()
	update_timer_ui()

	start_wave()

func spawn_npc():

	var npc

	var roll = randi() % 100

	# PRIORITY NPC
	if roll < priority_chance:

		npc = priority_npc_scene.instantiate()

		npc.is_priority = true
		npc.current_state = npc.NPCState.PRIORITY

	# NPC NORMAL
	else:

		npc = npc_scene.instantiate()

		npc.is_priority = false
		npc.current_state = npc.NPCState.QUEUE

	add_child(npc)

	npc.global_position = Vector2(144, 330)

	npc.variant_type = variants.pick_random()

	npc.setup()

	# SIGNAL
	npc.priority_failed.connect(_on_priority_failed)
	npc.priority_clicked.connect(_on_priority_clicked)

	queue.push_back(npc)

	update_queue()

func update_queue():

	for i in range(queue.size()):

		if is_instance_valid(queue[i]):

			queue[i].target_position = queue_positions[i]

			# NPC depan
			if i > 0:

				queue[i].npc_ahead = queue[i - 1]

			else:

				queue[i].npc_ahead = null

func remove_first_npc():

	if queue.is_empty():
		return

	var first_npc = queue.pop_front()

	if is_instance_valid(first_npc):

		first_npc.exit_queue()

	spawn_npc()

	update_queue()

func check_answer(color_name):

	if queue.is_empty():
		return

	var first_npc = queue[0]

	if !is_instance_valid(first_npc):
		return

	# PRIORITY NPC tidak boleh pakai sidebar
	if first_npc.is_priority:

		damage_player()
		print("SALAH - PRIORITY NPC")

		return

	if first_npc.variant_type == color_name:

		print("BENAR")

		add_score(10)

		remove_first_npc()

	else:

		wrong_sfx.play()

		print("SALAH")

		damage_player()

func _on_priority_clicked(npc):

	click_sfx.play()

	if !is_instance_valid(npc):
		return

	if queue.has(npc):

		queue.erase(npc)

		npc.current_state = npc.NPCState.EXITING

		npc.exit_queue()

		add_score(20)

		spawn_npc()

		update_queue()

func _on_priority_failed(npc):

	priority_wrong_sfx.play()

	damage_player()

	if queue.has(npc):

		queue.erase(npc)

		spawn_npc()

		update_queue()

func damage_player():

	hp -= 1

	update_hp_ui()

	print("HP:", hp)

	if hp <= 0:

		game_over()

func update_hp_ui():

	heart1.visible = hp >= 1
	heart2.visible = hp >= 2
	heart3.visible = hp >= 3

func game_over():

	game_started = false

	# STOP BGM
	if bgm.playing:
		bgm.stop()

	# PLAY GAME OVER SFX
	game_over_sfx.play()

	game_over_panel.visible = true

	final_score_text.visible = true
	final_score_text.text = "FINAL SCORE : " + str(score)

	get_tree().paused = true

func add_score(amount):

	score += amount

	update_score_ui()

	check_wave_progress()

func update_score_ui():

	score_text.text = "Score : " + str(score)

# =========================================
# BUTTON
# =========================================

func _on_red_button_pressed():

	click_sfx.play()

	check_answer("red")

func _on_green_button_pressed():

	click_sfx.play()

	check_answer("green")

func _on_blue_button_pressed():

	click_sfx.play()

	check_answer("blue")

# =========================================
# RESTART
# =========================================

func _on_restart_button_pressed():
	
	click_sfx.play()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	
	click_sfx.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")

# =========================================
# PAUSE
# =========================================

func _unhandled_input(event):

	if event.is_action_pressed("ui_cancel"):

		toggle_pause()

func toggle_pause():

	is_paused = !is_paused

	get_tree().paused = is_paused

	pause_panel.visible = is_paused

func _on_continue_pressed():

	click_sfx.play()
	toggle_pause()

func _on_menu_pressed():
	
	click_sfx.play()
	get_tree().paused = false

	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")

# ===========================
# TIMER & WAVE
# ===========================

func _process(delta):

	if !game_started:
		return

	if between_wave:
		return

	current_time -= delta

	update_timer_ui()

	if current_time <= 0:

		damage_player()

		current_time = wave_timer

func update_timer_ui():

	timer_text.text = "Time : " + str(int(current_time))

func update_wave_ui():

	wave_text.text = "Wave : " + str(current_wave)

func start_wave():

	game_started = false

	get_tree().paused = true

	start_wave_panel.visible = true
	start_wave_text.text = "WAVE " + str(current_wave)

	await get_tree().create_timer(3.0, true).timeout

	start_wave_panel.visible = false

	current_time = wave_timer

	game_started = true

	get_tree().paused = false

	while queue.size() < queue_positions.size():

		spawn_npc()

	update_wave_ui()
	update_timer_ui()

func check_wave_progress():

	if score >= next_wave_score:

		next_wave()

func next_wave():

	if between_wave:
		return

	between_wave = true

	game_started = false

	current_wave += 1

	next_wave_score += 250

	wave_timer -= 2

	if wave_timer < 10:
		wave_timer = 10

	clear_all_npc()

	get_tree().paused = true

	start_wave_panel.visible = true
	start_wave_text.text = "WAVE " + str(current_wave)

	await get_tree().create_timer(3.0, true).timeout

	start_wave_panel.visible = false

	current_time = wave_timer

	while queue.size() < queue_positions.size():

		spawn_npc()

	update_wave_ui()
	update_timer_ui()

	get_tree().paused = false

	game_started = true

	between_wave = false

func clear_all_npc():

	for npc in queue:

		if is_instance_valid(npc):

			npc.queue_free()

	queue.clear()
