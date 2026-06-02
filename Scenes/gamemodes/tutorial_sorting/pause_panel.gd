extends Control

@onready var continue_button = $BContainer1/Continue
@onready var menu_button = $BContainer2/Menu
@onready var restart_button = $BContainer3/Restart
@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound

func _ready():
	_connect_hover(continue_button)
	_connect_hover(menu_button)
	_connect_hover(restart_button)

func _connect_hover(button):
	button.mouse_entered.connect(
		func():
			if hover_sound:
				hover_sound.play()
			_hover_button(button))

	button.mouse_exited.connect(
		func():
			_unhover_button(button))

	button.button_down.connect(
		func():
			if click_sound:
				click_sound.play()
			_press_button(button))
	button.button_up.connect(
		func():
			_hover_button(button))
			
func _hover_button(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.12)

func _unhover_button(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.12)
	
func _press_button(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.93, 0.93), 0.05)
