extends Control

var button_type = null


func _ready():
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_Out")

func _on_game_1_pressed():
	button_type = "game1"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_game_2_pressed():
	button_type = "game2"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_game_3_pressed():
	button_type = "game3"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_skill_tree_pressed():
	button_type = "skillTree"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_main_menu_pressed():
	button_type = "mainMenu"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_timer_timeout() -> void:
	if button_type == "game1":
		get_tree().change_scene_to_file("res://Scenes/gamemodes/fifo/FIFOGame.tscn")

	elif button_type == "game2":
		get_tree().change_scene_to_file("res://Scenes/gamemodes/filo_sorting/FILOSortingGame.tscn")

	elif button_type == "game3":
		get_tree().change_scene_to_file("res://Scenes/gamemodes/fifopo_typing/Typing.tscn")

	elif button_type == "skillTree":
		get_tree().change_scene_to_file("res://Scenes/SkillTree.tscn")

	elif button_type == "mainMenu":
		get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")
