extends Node2D

@onready var key_sfx = $key_sfx
@onready var hurt_sfx = $hurt_sfx
@onready var gameover_sfx = $gameover_sfx

func play_key():
	key_sfx.play()

func play_hurt():
	hurt_sfx.play()

func play_gameOver():
	gameover_sfx.play()
