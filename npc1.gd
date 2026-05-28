extends CharacterBody2D

var target_position = Vector2.ZERO

func _process(delta):

	position = position.lerp(target_position, 4 * delta)
