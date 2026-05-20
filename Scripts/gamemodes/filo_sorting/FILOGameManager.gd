# FILOGameManager.gd
# Mengelola keseluruhan alur Gamemode FILO Sorting:
# - Setup level (buat rack + isi dengan potion acak)
# - Mendeteksi kondisi menang
# - Menghitung skor (moves & waktu)
# - Komunikasi dengan UI
extends Node2D
class_name FILOGameManager

# ─── SINYAL ──────────────────────────────────────────────────────────────────
signal game_won(total_moves: int, time_taken: float)
signal game_reset()
signal move_count_changed(new_count: int)

# ─── EXPORT (konfigurasi level dari Editor) ──────────────────────────────────
@export var num_racks: int = 4              # Jumlah rack (termasuk 1 buffer kosong)
@export var num_potion_types: int = 3       # Jumlah warna potion berbeda
@export var potions_per_type: int = 3       # Jumlah potion tiap warna
@export var rack_max_capacity: int = 5      # Kapasitas max per rack
@export var rack_horizontal_spacing: float = 200.0  # Jarak antar rack

# ─── NODE REFERENSI ──────────────────────────────────────────────────────────
@onready var drag_manager: DragManager = $HUD/DragManager
@onready var hud_layer: CanvasLayer = $HUD
@onready var drag_layer: CanvasLayer = $DragLayer
@onready var moves_label: Label = $HUD/MovesLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var win_panel: Panel = $HUD/WinPanel

# ─── STATE ───────────────────────────────────────────────────────────────────
var racks: Array[PotionRack] = []
var total_moves: int = 0
var elapsed_time: float = 0.0
var game_active: bool = false

# ─── LIFECYCLE ───────────────────────────────────────────────────────────────
func _ready() -> void:
	win_panel.visible = false
	_setup_game()
	_connect_signals()
	game_active = true
	print("[FILOGameManager] Game dimulai!")

func _process(delta: float) -> void:
	if game_active:
		elapsed_time += delta
		_update_timer_display()

# ─── SETUP GAME ──────────────────────────────────────────────────────────────

func _setup_game() -> void:
	print("SETUP GAME MULAI")
	_clear_existing_racks()
	_create_racks()
	_fill_racks_randomly()
	print("JUMLAH RACK:", racks.size())
	drag_manager.register_racks(racks)
	print("REGISTER RACKS SELESAI")
	drag_manager.set_drag_layer(drag_layer)
	print("[FILOGameManager] Setup selesai: %d racks, %d tipe potion" % [num_racks, num_potion_types])

func _clear_existing_racks() -> void:
	for rack in racks:
		if rack and is_instance_valid(rack):
			rack.queue_free()
	racks.clear()

func _create_racks() -> void:
	var total_width = (num_racks - 1) * rack_horizontal_spacing
	var start_x = -total_width / 2.0

	for i in num_racks:
		var rack = PotionRack.new()
		rack.rack_id = i
		rack.max_capacity = rack_max_capacity
		rack.position = Vector2(start_x + i * rack_horizontal_spacing + 600, 500)
		add_child(rack)
		racks.append(rack)

	print("[FILOGameManager] Dibuat %d racks" % racks.size())

func _fill_racks_randomly() -> void:
	# Buat kumpulan semua potion yang dibutuhkan
	var all_potion_types: Array = []
	for type_idx in num_potion_types:
		for _j in potions_per_type:
			all_potion_types.append(type_idx)   # 0=RED, 1=BLUE, 2=GREEN, dst

	# Acak urutan potion
	all_potion_types.shuffle()

	# Isi rack (kecuali rack terakhir yang jadi buffer kosong)
	var rack_idx = 0
	var potion_idx = 0

	while potion_idx < all_potion_types.size():
		# Skip rack terakhir (biarkan kosong sebagai buffer)
		if rack_idx >= num_racks - 1:
			rack_idx = 0

		var rack = racks[rack_idx]
		if not rack.is_full():
			var potion = Potion.new()
			potion.potion_type = all_potion_types[potion_idx] as Potion.PotionType
			rack.push(potion)
			potion_idx += 1

		rack_idx = (rack_idx + 1) % (num_racks - 1)

	print("[FILOGameManager] Potion berhasil diisi")
	_debug_print_state()

# ─── SINYAL & EVENT ──────────────────────────────────────────────────────────

func _connect_signals() -> void:
	drag_manager.move_made.connect(_on_move_made)
	drag_manager.invalid_move_attempted.connect(_on_invalid_move)

func _on_move_made(_from_rack: PotionRack, _to_rack: PotionRack, _potion: Potion) -> void:
	total_moves += 1
	move_count_changed.emit(total_moves)
	_update_moves_display()

	# Cek kondisi menang setelah setiap move
	if _check_win_condition():
		_trigger_win()

func _on_invalid_move(_from: PotionRack, _to: PotionRack) -> void:
	# Bisa tambahkan SFX atau visual feedback di sini
	pass

# ─── WIN CONDITION ───────────────────────────────────────────────────────────

## Kondisi menang: semua rack yang TIDAK kosong sudah tersortir sempurna
## (setiap rack hanya berisi satu warna potion)
func _check_win_condition() -> bool:
	var sorted_count = 0
	var non_empty_racks = 0

	for rack in racks:
		if not rack.is_empty():
			non_empty_racks += 1
			if rack.is_sorted():
				sorted_count += 1

	# Menang jika semua rack non-kosong sudah sorted
	var all_sorted = (sorted_count == non_empty_racks and non_empty_racks == num_potion_types)
	print("[FILOGameManager] Win check: %d/%d sorted, menang=%s" % [sorted_count, non_empty_racks, str(all_sorted)])
	return all_sorted

func _trigger_win() -> void:
	game_active = false
	print("[FILOGameManager] 🎉 MENANG! Moves: %d, Waktu: %.1fs" % [total_moves, elapsed_time])
	game_won.emit(total_moves, elapsed_time)
	_show_win_screen()

# ─── UI UPDATE ───────────────────────────────────────────────────────────────

func _update_moves_display() -> void:
	if moves_label:
		moves_label.text = "Moves: %d" % total_moves

func _update_timer_display() -> void:
	if timer_label:
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _show_win_screen() -> void:
	if win_panel:
		win_panel.visible = true
		var win_label = win_panel.get_node_or_null("WinLabel")
		if win_label:
			win_label.text = "🎉 SELESAI!\nMoves: %d\nWaktu: %.1f detik" % [total_moves, elapsed_time]

# ─── RESET ───────────────────────────────────────────────────────────────────

func reset_game() -> void:
	total_moves = 0
	elapsed_time = 0.0
	game_active = false
	win_panel.visible = false
	_setup_game()
	game_active = true
	game_reset.emit()
	print("[FILOGameManager] Game di-reset")

# ─── DEBUG ───────────────────────────────────────────────────────────────────

func _debug_print_state() -> void:
	print("=== STATE RACK ===")
	for rack in racks:
		var types = rack.get_stack_types().map(func(t): return Potion.POTION_NAMES[t])
		print("  Rack %d [%d/%d]: %s" % [rack.rack_id, rack.get_size(), rack.max_capacity, str(types)])
	print("==================")
