extends Node2D
class_name Player

@onready var sprite = $Player/AnimatedSprite2D

func _ready():
	# Pastikan sinyal terhubung dengan aman
	if sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.disconnect(_on_animation_finished)
		
	sprite.animation_finished.connect(_on_animation_finished)
	
	# PERBAIKAN: Cek animasi di dalam resource 'sprite_frames'
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func play_attack():
	if is_instance_valid(sprite):
		sprite.play("attack")

func play_hurt():
	if is_instance_valid(sprite):
		sprite.play("hurt") 
		AudioManager.play_hurt()

func play_death():
	if is_instance_valid(sprite):
		sprite.play("death")
		AudioManager.play_key()
		# queue_free() dihapus agar visual tidak hilang dan crash

# FUNGSI OTOMATIS KEMBALI KE IDLE
func _on_animation_finished():
	if not is_instance_valid(sprite): return
	
	# Jika player baru saja selesai melakukan animasi "attack" atau "hurt",
	# kembalikan animasinya ke "idle" secara otomatis.
	if sprite.animation == "attack" or sprite.animation == "hurt":
		# PERBAIKAN: Akses lewat sprite_frames
		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
