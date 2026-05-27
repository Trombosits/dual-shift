extends Node2D

@export var SpeedRate: float = 3.0
@onready var enemy_2d = $CharacterBody2D/Mushroom2D
var difficulty: int = 1

var GENERATED_CHARS: Array = []
var char_index: int = 0
var is_dead: bool = false # Menandai apakah musuh sudah mati atau belum

const chars: Array = [

	"Act", "Add", "Age", "Bit", "Bus", "Dim", "Key", "Map", "New", "Not", "Out", "Pop", "Ram", "Row", "Set", "Top", "Two", "Use",
	"Data", "Node", "Edge", "Tree", "Heap", "Hash", "List", "Root", "Leaf", "Path", "Push", "Peek", "Fifo", "Lifo", "Size", "Null", 
	"Byte", "Code", "Item", "Link", "Loop", "Main", "Next", "Prev", "Sort", "Void", "Type", "File", "Grid", "Rand", "Tree", "Graph",
	

	"Array", "Stack", "Queue", "Graph", "Index", "Child", "Value", "Table", "Match", "Merge", "Count", "Block", "Class", "Logic", 
	"State", "Range", "Order", "Check", "Print", "Break", "Input", "Clear", "Trace", "Write", "Alloc", "Depth", "Width", "Reset", 
	"Query", "Pivot", "Shell", "Build", "First", "Front", "Parse", "Field", "Space", "Local", "Cache", "Tuple", "Valid", "Empty",
	

	"Linked", "Binary", "Matrix", "Vector", "String", "Record", "Linear", "Search", "Memory", "Object", "Parent", "Height", "Weight", 
	"Degree", "Vertex", "Bucket", "Pointer", "HashMap", "Sorting", "Dryrun", "Balance", "Capture", "Traverse", "Dynamic", "Boolean", 
	"Element", "Storage", "Address", "Precede", "Success", "Cluster", "Compare", "Execute", "Compile", "Console", "Library", "Runtime",
	"Pointer", "Overflow", "Iterator", "Function", "Argument", "Constant", "Instance", "Ancestor", "Adjacency", "Recursion", "Algorithm"
]

@onready var _body: CharacterBody2D = $CharacterBody2D
@onready var _label: Label = _body.get_node("Label")

func _ready():
	randomize()
	var filtered_chars = _get_filtered_words()
	
	for i in range(difficulty):
		if filtered_chars.size() > 0:
			var random_index = randi() % filtered_chars.size()
			GENERATED_CHARS.append(filtered_chars[random_index].to_upper())

	_label.text = " ".join(GENERATED_CHARS)
	play_run()

func _get_filtered_words() -> Array:
	var filtered = []
	
	for word in chars:
		match difficulty:
			1:  # Easy - Hanya kata berpanjang 3 huruf
				if word.length() == 3:
					filtered.append(word)
			2:  # Intermediate - 5 letters
				if word.length() == 5:
					filtered.append(word)
			3:  # Hardcore - 3, 5-7 letters
				if word.length() == 3 || (word.length() >= 5 && word.length() <= 7):
					filtered.append(word)
	
	return filtered if !filtered.is_empty() else chars.duplicate()

func _physics_process(_delta):
	if is_dead:
		# Jika monster mati, hentikan pergerakan sepenuhnya
		_body.velocity = Vector2.ZERO
		_body.move_and_slide()
		return

	_label.text = " ".join(GENERATED_CHARS)
	
	# Hitung kecepatan dasar berdasarkan kesulitan
	var current_speed = SpeedRate * 50
	
	# LOGIKA PERLAMBATAN JIKA ADA BOSS:
	# Jika spawner mendeteksi ada boss yang hidup, perlambat jalan jamur (dikali 0.3)
	if get_parent() and get_parent().has_method("is_boss_present") and get_parent().is_boss_present():
		current_speed *= 0.3 # Mengurangi kecepatan menjadi 30% saja. Ubah angka ini sesuai selera.

	_body.velocity.x = -current_speed
	_body.move_and_slide()


# ==========================================
# FUNGSI KONTROL ANIMASI MONSTER
# ==========================================

func play_run():
	if is_dead: return
	enemy_2d.play("run") # Pastikan ada animasi bernama "run" di SpriteFrames

func play_hit():
	if is_dead: return
	enemy_2d.play("hit") # Pastikan ada animasi bernama "hit" di SpriteFrames
	
	# Tunggu sampai animasi hit selesai diputar, lalu kembali jalan
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
