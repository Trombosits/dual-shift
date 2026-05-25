extends Node2D

@export var SpeedRate: float = 3.0
@onready var enemy_2d = $CharacterBody2D/Mushroom2D
var difficulty: int = 1

var GENERATED_CHARS: Array = []
var char_index: int = 0
var is_dead: bool = false # Menandai apakah musuh sudah mati atau belum

const chars: Array = ["Act", "Add", "Age", "Aid", "Aim", "Air", "All", "And", "Ant", "Any", "Are", "Arm", "Art", "Ask", "Ate", "Bad", "Bag", "Ban", "Bar", "Bat", "Bay", "Bed", "Bee", "Beg", "Bet", "Bid", "Big", "Bit", "Box", "Boy", "Bus", "But", "Buy",
"Can", "Cap", "Car", "Cat", "Cow", "Cup", "Cut", "Day", "Die", "Dig", "Dog", "Dot", "Dry", "Due","Eat", "Egg", "End", "Eye", "Far", "Fat", "Few", "Fit", "Fix", "Fly", "For", "Fun", "Gas", "Get", "God", "Got", "Gut", "Hat", "Her",
"Him", "His", "Hit", "Hot", "How", "Ice", "Its", "Job", "Joy", "Key", "Kid", "Law", "Lay", "Leg", "Let", "Lie", "Lip", "Lot", "Low", "Man", "Map", "May", "Men", "Met", "Mix", "New", "Not", "Now","Nut", "Off", "Old", "One","Out",
"Own", "Pay", "Pen", "Pet", "Pig", "Pot", "Put", "Rat", "Red", "Run", "Sad", "Say", "See", "Set", "Sew", "She", "Sit", "Six", "Sky", "Son", "Sun", "Ten", "The", "Tie", "Too", "Top", "Try", "Two", "Use", "War", "Was", "Way", "Who",
"Why", "Win", "Yesb", "Yet", "You", "Zoo",
	
"Amber", "Angel", "Baker","Beach", "Bloom", "Candy", "Chair", "Clove", "Crisp","Dance", "Dizzy", "Dwarf", "Eagle", "Earth", "Fairy", "Flame", "Frost", "Ghost", "Globe", "Grape", "Grind",
"Haste", "Honey", "Ivory", "Jelly", "Joust", "Juice", "Karma", "Koala", "Latch", "Lemon", "Light", "Lunar", "Mango", "Mirth", "Mossy", "Music", "Noble", "Nurse", "Nymph", "Ocean","Olive", "Opera", "Otter", "Pearl", "Piano",
"Plume", "Pouch", "Query", "Quilt","Rider", "River", "Robin", "Rusty", "Scent", "Smile", "Sugar", "Swoop", "Table", "Thump", "Tiger", "Toast", "Tread", "Umbra", "Udder", "Usher", "Vapor", "Vivid", "Vixen", "Watch", "Wheat",
"Whisk", "Wacky", "Youth", "Yodel", "Zesty", "Zoned",
	
"Believe", "Journey","Lantern", "Library", "Mystery", "Octopus", "Passion", "Silence", "Whisper", "Wonders", "Balance", "Capture","Curtain", "Fortune", "Harvest", "Inspire",
"Justice", "Kingdom", "Miracle", "Mission", "Nature", "Outside", "Pattern", "Picture", "Promise", "Rainbow", "Station", "Teacher", "Treasure", "Village", "Visitor", "Waiting", "Wishing", "Fashion", "Fiction", "Garment", "Glimmer",
"Journey", "Perfect", "Sandman", "Serpent", "Thunder", "Trouble", "Twinkle", "Venture", "Whistle"
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
