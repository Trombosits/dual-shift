extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

var target_position = Vector2.ZERO

var variant_type = ""

func _ready():

	pass

func _process(delta):

	global_position = global_position.lerp(target_position, 4.0 * delta)

func setup():

	update_variant()

func update_variant():

	if variant_type == "red":

		anim.play("red_idle")

	elif variant_type == "green":

		anim.play("green_idle")

	elif variant_type == "blue":

		anim.play("blue_idle")
