extends Node2D
class_name Player

@onready var sprite = $Player/AnimatedSprite2D

func _ready():
	# Hubungkan sinyal selesai animasi ke fungsi kustom di bawah ini
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func play_attack():
	sprite.play("attack")

func play_hurt():
	sprite.play("hurt") 
	AudioManager.play_hurt()

func play_death():
	sprite.play("death")
	AudioManager.play_key()
	sprite.queue_free()

# FUNGSI OTOMATIS KEMBALI KE IDLE
func _on_animation_finished():
	# Jika player baru saja selesai melakukan animasi "attack" atau "hurt",
	# kembalikan animasinya ke "idle" secara otomatis.
	if sprite.animation == "attack" or sprite.animation == "hurt":
		sprite.play("idle")
