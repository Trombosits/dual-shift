extends Node2D

@export var npc_scene : PackedScene
@onready var heart1 = $"../UI/HPContainer/Heart1"
@onready var heart2 = $"../UI/HPContainer/Heart2"
@onready var heart3 = $"../UI/HPContainer/Heart3"
@onready var game_over_panel = $"../UI/GameOverPanel"


var queue = []

var hp = 3

var variants = ["red", "green", "blue"]

var queue_positions = [
	Vector2(136, 100),
	Vector2(136, 120),
	Vector2(136, 140),
	Vector2(136, 160),
	Vector2(136, 180),
]

func _ready():

	update_hp_ui()

	for i in range(5):
		spawn_npc()

func spawn_npc():

	if npc_scene == null:
		return

	var npc = npc_scene.instantiate()

	add_child(npc)

	npc.position = Vector2(136,200)

	npc.variant_type = variants.pick_random()

	npc.setup()

	queue.push_back(npc)

	update_queue()

func update_queue():

	for i in range(queue.size()):

		queue[i].target_position = queue_positions[i]

func remove_first_npc():

	if queue.size() == 0:
		return

	var first_npc = queue.pop_front()

	first_npc.queue_free()

	spawn_npc()

	update_queue()

func check_answer(color_name):

	if queue.size() == 0:
		return

	var first_npc = queue[0]

	if first_npc.variant_type == color_name:

		print("BENAR")

		remove_first_npc()

	else:

		print("SALAH")

		damage_player()

func damage_player():

	hp -= 1

	update_hp_ui()

	print("HP:", hp)

	if hp <= 0:

		game_over()

func game_over():

	game_over_panel.visible = true

	get_tree().paused = true

func _input(event):

	if event.is_action_pressed("ui_accept"):

		check_answer("red")


func _on_red_button_pressed() -> void:
	check_answer("red")


func _on_green_button_pressed() -> void:
	check_answer("green")


func _on_blue_button_pressed() -> void:
	check_answer("blue")

func update_hp_ui():

	heart1.visible = hp >= 1
	heart2.visible = hp >= 2
	heart3.visible = hp >= 3


func _on_restart_button_pressed() -> void:
	get_tree().paused = false

	get_tree().reload_current_scene()
	
