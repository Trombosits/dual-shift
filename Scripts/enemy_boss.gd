extends Node2D

@export var SpeedRate: float = 1.5 # Boss berjalan lebih lambat namun mematikan
@onready var enemy_2d = $boss/boss2D # Sesuaikan dengan nama AnimatedSprite2D di scene Boss Anda
@onready var _body: CharacterBody2D = $boss
@onready var _label: Label = _body.get_node("Label")

var GENERATED_CHARS: Array = []
var char_index: int = 0
var is_dead: bool = false
var is_boss: bool = true # VARIABEL UTAMA: Dibaca oleh typing.gd untuk priority target

# List Kata Khusus Boss (Kata-kata Panjang/Keren)
const boss_words: Array = [
	"CHAMPION", "GUARDIAN", "OVERLORD", "DOMINATOR", "BLIZZARD", 
	"VANGUARD", "APOCALYPSE", "TYRANT", "BEHEMOTH", "IMMORTAL"
]

func _ready():
	randomize()
	
	# Boss diberikan 3 kata acak sekaligus (sebagai pengganti HP tebal)
	for i in range(3):
		var random_index = randi() % boss_words.size()
		GENERATED_CHARS.append(boss_words[random_index].to_upper())

	_label.text = " ".join(GENERATED_CHARS)
	play_run()

func _physics_process(_delta):
	if is_dead:
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		return

	# Tampilkan sisa kata yang harus diketik di atas kepala boss
	_label.text = " ".join(GENERATED_CHARS)
	_body.velocity.x = -SpeedRate * 50
	_body.move_and_slide()

func play_run():
	if is_dead: return
	if enemy_2d and enemy_2d.has_method("play"):
		enemy_2d.play("run")

func play_hit():
	if is_dead: return
	if enemy_2d and enemy_2d.has_method("play"):
		enemy_2d.play("hit")
	
	await enemy_2d.animation_finished
	if not is_dead and enemy_2d.animation == "hit":
		play_run()

func play_die():
	if is_dead: return
	is_dead = true
	_label.visible = false
	
	if enemy_2d and enemy_2d.has_method("play"):
		enemy_2d.stop()
		enemy_2d.play("die")
		
	# SOLUSI AMAN: Jangan pakai 'await animation_finished' karena rawan macet jika di-set Loop.
	# Gunakan timer manual bawaan code selama 1 detik (atau sesuaikan durasi animasi mati Anda)
	await get_tree().create_timer(1.0).timeout
	
	queue_free() # Menghapus total dari game
