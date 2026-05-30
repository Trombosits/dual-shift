extends Node2D

var button_type = null

func _ready() -> void:
	$CanvasLayer2.show()
	$CanvasLayer2/Story1/Timer.start()
	$CanvasLayer2/Story1/AnimationPlayer.play("Text_In")

func _on_button_pressed() -> void:
	button_type = "next"
	$CanvasLayer2.show()
	$CanvasLayer2/Story1/Timer.start(3)
	$CanvasLayer2/Story1/AnimationPlayer.play("Text_Out")
	
func _on_timer_timeout():
	if button_type == "next":
		get_tree().change_scene_to_file("res://Scenes/tutorial/guild_master.tscn")
