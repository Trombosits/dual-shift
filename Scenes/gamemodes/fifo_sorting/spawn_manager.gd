extends Node2D

@export var npc_scene : PackedScene

var queue = []

var hp = 3

var colors = ["red", "green", "blue"]

var queue_positions = [
	Vector2(136, 80),
	Vector2(136, 90),
	Vector2(136, 100),
]

func _ready():

	for i in range(3):
		spawn_npc()

func spawn_npc():

	var npc = npc_scene.instantiate()

	add_child(npc)

	npc.position = Vector2(138, 160)

	npc.color_type = colors.pick_random()

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

	if first_npc.color_type == color_name:

		print("BENAR")

		remove_first_npc()

	else:

		print("SALAH")

		damage_player()

func damage_player():

	hp -= 1

	print("HP:", hp)

	if hp <= 0:

		game_over()

func game_over():

	print("GAME OVER")

func _input(event):

	if event.is_action_pressed("ui_accept"):

		check_answer("red")


func _on_red_button_pressed() -> void:
	check_answer("red")


func _on_green_button_pressed() -> void:
	check_answer("green")


func _on_blue_button_pressed() -> void:
	check_answer("blue")
