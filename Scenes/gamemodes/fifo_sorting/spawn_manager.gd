extends Node2D

@export var priority_npc_scene : PackedScene
@export var npc_scene : PackedScene

@onready var heart1 = $"../UI/HPContainer/Heart1"
@onready var heart2 = $"../UI/HPContainer/Heart2"
@onready var heart3 = $"../UI/HPContainer/Heart3"

@onready var game_over_panel = $"../UI/GameOverPanel"
@onready var pause_panel = $"../UI/PausePanel"

@onready var score_text = $"../UI/ScorePanel/ScoreText"

var queue = []

var hp = 3
var score = 0

var is_paused = false

var variants = ["red", "green", "blue"]

var priority_chance = 10

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

	for i in range(10):
		spawn_npc()

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

	npc.global_position = Vector2(136, 330)

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

		print("SALAH")

		damage_player()

func _on_priority_clicked(npc):

	if !is_instance_valid(npc):
		return

	if queue.has(npc):

		queue.erase(npc)

		npc.current_state = npc.NPCState.EXITING

		npc.exit_queue()

		add_score(20)

		update_queue()

func _on_priority_failed():

	damage_player()

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

	game_over_panel.visible = true

	get_tree().paused = true

func add_score(amount):

	score += amount

	update_score_ui()

func update_score_ui():

	score_text.text = "Score : " + str(score)

# =========================================
# BUTTON
# =========================================

func _on_red_button_pressed():

	check_answer("red")

func _on_green_button_pressed():

	check_answer("green")

func _on_blue_button_pressed():

	check_answer("blue")

# =========================================
# RESTART
# =========================================

func _on_restart_button_pressed():

	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():

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

	toggle_pause()

func _on_menu_pressed():

	get_tree().paused = false

	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")
