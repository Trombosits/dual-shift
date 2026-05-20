# PotionRack.gd
# Merepresentasikan satu buah rak/tumpukan potion.
# Mengimplementasikan struktur data STACK (FILO: First In, Last Out).
# - push()  → taruh potion di paling ATAS
# - pop()   → ambil potion dari paling ATAS
# - peek()  → lihat potion paling atas tanpa mengambilnya
extends Area2D
class_name PotionRack

# ─── SINYAL ──────────────────────────────────────────────────────────────────
signal rack_clicked(rack: PotionRack)           # Saat rack diklik player
signal stack_changed(rack: PotionRack)          # Saat isi stack berubah

# ─── EXPORT (bisa di-set dari Editor) ────────────────────────────────────────
@export var rack_id: int = 0
@export var max_capacity: int = 5               # Maksimal potion dalam 1 rack
@export var potion_spacing_y: float = 75.0      # Jarak vertikal antar potion
@export var rack_width: float = 70.0

# ─── INTERNAL STATE ──────────────────────────────────────────────────────────
# Stack disimpan sebagai Array — index 0 = BOTTOM, index -1 = TOP
# Ini adalah implementasi FILO: yang terakhir masuk, pertama keluar
var _stack: Array[Potion] = []

var _is_selected: bool = false          # True saat rack ini dipilih player
var _rack_body: ColorRect               # Visual placeholder rack
var _click_area: Area2D                 # Area deteksi klik

# ─── LIFECYCLE ───────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_rack_visual()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(
		rack_width,
		max_capacity * potion_spacing_y
		)
	collision.shape = shape
	collision.position = Vector2(
		0,
		-(max_capacity * potion_spacing_y) / 2
		)
	add_child(collision)
	input_pickable = true
	input_event.connect(_on_area_input_event)

# ─── SETUP VISUAL ────────────────────────────────────────────────────────────
func _build_rack_visual() -> void:
	# Body rack (placeholder visual)
	_rack_body = ColorRect.new()
	_rack_body.size = Vector2(rack_width, max_capacity * potion_spacing_y + 20)
	_rack_body.position = Vector2(-rack_width / 2, -(max_capacity * potion_spacing_y + 20))
	_rack_body.color = Color(0.3, 0.25, 0.15)    # Warna kayu coklat gelap
	add_child(_rack_body)

	# Label ID rack (untuk debug)
	var id_label = Label.new()
	id_label.text = "Rack %d" % rack_id
	id_label.position = Vector2(-30, 10)
	add_child(id_label)

# ─── STACK OPERATIONS (Implementasi FILO) ────────────────────────────────────

## PUSH: Taruh potion di paling atas stack
## Return: true jika berhasil, false jika rack penuh
func push(potion: Potion) -> bool:
	if is_full():
		print("[Rack %d] PUSH gagal: rack penuh (%d/%d)" % [rack_id, _stack.size(), max_capacity])
		return false

	# Lepaskan dari parent lama dan masukkan ke rack ini
	if potion.get_parent():
		potion.reparent(self)
	else:
		add_child(potion)

	potion.rack_owner = self
	_stack.append(potion)               # Tambah ke belakang array = TOP of stack

	_reposition_potions()               # Update posisi visual semua potion
	stack_changed.emit(self)

	print("[Rack %d] PUSH: %s → stack size=%d" % [rack_id, Potion.POTION_NAMES[potion.potion_type], _stack.size()])
	return true

## POP: Ambil potion dari paling atas stack
## Return: Potion yang diambil, atau null jika stack kosong
func pop() -> Potion:
	if is_empty():
		print("[Rack %d] POP gagal: stack kosong" % rack_id)
		return null

	var top_potion = _stack.pop_back()  # Ambil dari belakang array = TOP of stack
	top_potion.rack_owner = null

	stack_changed.emit(self)
	print("[Rack %d] POP: %s → stack size=%d" % [rack_id, Potion.POTION_NAMES[top_potion.potion_type], _stack.size()])
	return top_potion

## PEEK: Lihat potion paling atas tanpa mengambilnya
## Return: Potion teratas, atau null jika kosong
func peek() -> Potion:
	if is_empty():
		return null
	return _stack.back()               # Index terakhir = TOP of stack

## Cek apakah boleh menerima potion tertentu
## Boleh taruh JIKA: rack kosong, atau warna paling atas sama dengan potion yang datang
func can_accept(potion: Potion) -> bool:
	if is_full():
		return false
	if is_empty():
		return true
	# Opsional: uncomment untuk aturan warna harus sama
	# return peek().potion_type == potion.potion_type
	return true

# ─── HELPER PROPERTIES ───────────────────────────────────────────────────────

func is_full() -> bool:
	return _stack.size() >= max_capacity

func is_empty() -> bool:
	return _stack.is_empty()

func get_size() -> int:
	return _stack.size()

## Cek apakah rack ini sudah tersortir sempurna
## Tersortir = semua potion di rack ini bertipe sama
func is_sorted() -> bool:
	if _stack.is_empty() or _stack.size() == 1:
		return true
	var base_type = _stack[0].potion_type
	for potion in _stack:
		if potion.potion_type != base_type:
			return false
	return true

## Ambil semua tipe dalam stack (untuk debugging)
func get_stack_types() -> Array:
	return _stack.map(func(p): return p.potion_type)

# ─── VISUAL UPDATE ───────────────────────────────────────────────────────────

## Atur ulang posisi semua potion sesuai urutan stack
func _reposition_potions() -> void:
	for i in _stack.size():
		var potion = _stack[i]
		# Potion index 0 (bottom) ada di paling bawah visual
		var target_y = -( (i + 1) * potion_spacing_y )
		var tween = create_tween()
		tween.tween_property(potion, "position", Vector2(0, target_y), 0.15)\
			 .set_ease(Tween.EASE_OUT)

## Set visual "terpilih" saat rack diklik player
func set_selected(value: bool) -> void:
	_is_selected = value
	if _rack_body:
		if value:
			_rack_body.color = Color(0.5, 0.45, 0.2)   # Lebih terang = terpilih
		else:
			_rack_body.color = Color(0.3, 0.25, 0.15)  # Normal

## Highlight sebagai target saat player menahan potion
func set_highlighted_as_target(value: bool) -> void:
	if _rack_body:
		if value:
			_rack_body.color = Color(0.2, 0.5, 0.2)    # Hijau = bisa drop di sini
		else:
			_rack_body.color = Color(0.3, 0.25, 0.15)

# ─── INISIALISASI KONTEN ─────────────────────────────────────────────────────

## Isi rack dengan array tipe potion (dipanggil oleh GameManager saat setup)
func initialize_with_potions(types: Array) -> void:
	for type in types:
		var potion = Potion.new()
		potion.potion_type = type
		push(potion)
		
func _on_area_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

			print("RACK KLIK:", rack_id)

			rack_clicked.emit(self)
