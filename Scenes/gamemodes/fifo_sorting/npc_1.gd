extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

var target_position = Vector2.ZERO

var color_type = ""

func _ready():

	anim.play("idle")

	update_color()

func _process(delta):

	global_position = global_position.lerp(target_position, 4.0 * delta)

func update_color():

	if color_type == "red":
		anim.modulate = Color.RED

	elif color_type == "green":
		anim.modulate = Color.GREEN

	elif color_type == "blue":
		anim.modulate = Color.BLUE
