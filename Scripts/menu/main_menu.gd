extends Control

var button_type = null
@onready var main_button: VBoxContainer = $Main_Button
@onready var setting: Panel = $Setting

func _ready():
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_Out")
	main_button.visible = true
	setting.visible = false

func _on_new_game_pressed():
	button_type = "newGame"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_continue_pressed():
	button_type = "continue"
	$Fade_Transition.show()
	$Fade_Transition/Timer.start()
	$Fade_Transition/AnimationPlayer.play("Fade_In")

func _on_setting_pressed():
	main_button.visible = false
	setting.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_timer_timeout():
	if button_type == "newGame":
		get_tree().change_scene_to_file("res://Scenes/tutorial/first_scene.tscn")
	
	elif button_type == "continue":
		get_tree().change_scene_to_file("res://Scenes/menu/game_menu.tscn")
	
	elif button_type == "setting":
		print("Masuk menu setting")


func _on_back_pressed():
	main_button.visible = true
	setting.visible = false
