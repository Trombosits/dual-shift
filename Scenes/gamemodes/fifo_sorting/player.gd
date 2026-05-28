extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

var target_position = Vector2.ZERO

func _ready():
	anim.play("idle")
