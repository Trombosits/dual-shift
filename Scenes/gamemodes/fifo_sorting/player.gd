extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

var target_position = Vector2.ZERO

func _ready():
	anim.play("idle")

func _on_main_menu_button_pressed():

	get_tree().paused = false

	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")
