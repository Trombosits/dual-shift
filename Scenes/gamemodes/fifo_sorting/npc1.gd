extends CharacterBody2D

enum NPCState {
	QUEUE,
	EXITING,
	PRIORITY
}

signal priority_failed
signal priority_clicked

@onready var anim = $AnimatedSprite2D

var target_position = Vector2.ZERO
var variant_type = ""

var move_path = []
var current_path_index = 0
var move_speed = 80.0
var wait_timer = 0.0
var is_waiting = false

var current_state = NPCState.QUEUE
var priority_timer = 5.0

var is_priority = false

func _ready():

	print(anim.sprite_frames.get_animation_names())

func _process(delta):

	match current_state:

		NPCState.QUEUE:

			process_queue(delta)

		NPCState.PRIORITY:

			process_priority(delta)

		NPCState.EXITING:

			follow_path(delta)

# =========================
# SETUP
# =========================

func setup():

	if current_state == NPCState.PRIORITY:

		anim.play("priority_idle")

	else:

		update_variant()

# =========================
# NORMAL QUEUE
# =========================

func process_queue(delta):

	global_position = global_position.lerp(target_position, 4.0 * delta)

	if global_position.distance_to(target_position) < 5:

		var idle_anim = variant_type + "_idle"

		if anim.animation != idle_anim:

			anim.play(idle_anim)

# =========================
# PRIORITY QUEUE
# =========================

func process_priority(delta):

	global_position = global_position.lerp(target_position, 4.0 * delta)

	if global_position.distance_to(target_position) < 5:

		if anim.animation != "priority_idle":

			anim.play("priority_idle")

	priority_timer -= delta

	if priority_timer <= 0:

		fail_priority()

# =========================
# VARIANT
# =========================

func update_variant():

	if variant_type == "red":

		anim.play("red_idle")

	elif variant_type == "green":

		anim.play("green_idle")

	elif variant_type == "blue":

		anim.play("blue_idle")

# =========================
# EXIT MOVEMENT
# =========================

func follow_path(delta):

	# WAIT DI CLERK
	if is_waiting:

		wait_timer -= delta

		if wait_timer <= 0:

			is_waiting = false

			current_path_index += 1

		return

	# SELESAI PATH
	if current_path_index >= move_path.size():

		queue_free()

		return

	var target = move_path[current_path_index]

	var direction = Vector2.ZERO

	var dx = target.x - global_position.x
	var dy = target.y - global_position.y

	# GERAK X DULU
	if abs(dx) > 5:

		direction.x = sign(dx)

	# BARU GERAK Y
	elif abs(dy) > 5:

		direction.y = sign(dy)

	global_position += direction * move_speed * delta

	update_walk_animation(direction)

	# SAMPAI TITIK
	if abs(dx) < 5 and abs(dy) < 5:

		global_position = target

		# PRIORITY NPC BERHENTI DI CLERK
		if is_priority and current_path_index == 2:

			is_waiting = true

			wait_timer = 2.0

		else:

			current_path_index += 1

# =========================
# WALK ANIMATION
# =========================

func update_walk_animation(direction):

	var anim_name = ""

	# PRIORITY NPC
	if is_priority:

		if abs(direction.x) > abs(direction.y):

			if direction.x > 0:
				anim_name = "priority_walk_right"
			else:
				anim_name = "priority_walk_left"

		else:

			if direction.y > 0:
				anim_name = "priority_walk_down"
			else:
				anim_name = "priority_walk_up"

	# NPC NORMAL
	else:

		if abs(direction.x) > abs(direction.y):

			if direction.x > 0:
				anim_name = variant_type + "_walk_right"
			else:
				anim_name = variant_type + "_walk_left"

		else:

			if direction.y > 0:
				anim_name = variant_type + "_walk_down"
			else:
				anim_name = variant_type + "_walk_up"

	if anim.animation != anim_name:

		anim.play(anim_name)

# =========================
# EXIT QUEUE
# =========================

func exit_queue():

	current_state = NPCState.EXITING

	current_path_index = 0

	# PRIORITY NPC
	if is_priority:

		move_path = [
			Vector2(350, global_position.y),
			Vector2(350, 100),
			Vector2(440, 100),
			Vector2(440, 330)
		]

	# NPC NORMAL
	else:

		move_path = [
			Vector2(350, global_position.y),
			Vector2(350, 250),
			Vector2(435, 250),
			Vector2(435, 330)
		]

# =========================
# CLICK PRIORITY NPC
# =========================

func _on_area_2d_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

			if current_state == NPCState.PRIORITY:

				priority_clicked.emit(self)

# =========================
# PRIORITY FAIL
# =========================

func fail_priority():

	print("PRIORITY FAILED")

	priority_failed.emit()

	queue_free()
