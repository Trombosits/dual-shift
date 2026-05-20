# DragManager.gd
# Mengelola mekanik "klik untuk pilih, klik lagi untuk taruh" antar rack.
# Menggunakan pola CLICK-TO-SELECT (bukan drag-drop yang rumit):
#   1. Klik rack pertama  → ambil potion teratas (POP) & highlight rack sumber
#   2. Klik rack kedua    → taruh potion (PUSH) ke rack tujuan
#   3. Klik rack sama     → batalkan pilihan
extends Node
class_name DragManager

func _ready():
	add_to_group("drag_manager")
	print("DRAG MANAGER READY")

# ─── SINYAL ──────────────────────────────────────────────────────────────────
signal move_made(from_rack: PotionRack, to_rack: PotionRack, potion: Potion)
signal invalid_move_attempted(from_rack: PotionRack, to_rack: PotionRack)
signal selection_changed(selected_rack: PotionRack)  # null = deselect

# ─── STATE ───────────────────────────────────────────────────────────────────
var selected_rack: PotionRack = null        # Rack yang sedang "dipegang"
var held_potion: Potion = null              # Potion yang sedang "dipegang"
var all_racks = []       # Referensi ke semua rack

# Node untuk potion yang "melayang" mengikuti cursor
var _floating_potion_display: ColorRect     # Placeholder visual saat drag
var _drag_layer: CanvasLayer

# ─── SETUP ───────────────────────────────────────────────────────────────────

## Dipanggil oleh GameManager untuk mendaftarkan semua rack
func register_racks(racks) -> void:
	all_racks = racks
	print("REGISTERING RACKS...")
	for rack in all_racks:
		print("CONNECT RACK:", rack.rack_id)
		if not rack.rack_clicked.is_connected(_on_rack_clicked):
			rack.rack_clicked.connect(_on_rack_clicked)
	print("TOTAL RACK:", all_racks.size())

func set_drag_layer(layer: CanvasLayer) -> void:
	_drag_layer = layer
	_build_floating_display()

func _build_floating_display() -> void:
	if not _drag_layer:
		return
	_floating_potion_display = ColorRect.new()
	_floating_potion_display.size = Vector2(50, 70)
	_floating_potion_display.visible = false
	_floating_potion_display.z_index = 100
	_drag_layer.add_child(_floating_potion_display)

# ─── CORE LOGIC ──────────────────────────────────────────────────────────────

func _on_rack_clicked(clicked_rack) -> void:
	print("DRAGMANAGER TERIMA KLIK:", clicked_rack.rack_id)
	# ── KASUS 1: Belum ada yang dipilih → pilih rack ini ──────────────────
	if selected_rack == null:
		_try_select_rack(clicked_rack)
		return

	# ── KASUS 2: Klik rack yang sama → batalkan pilihan ───────────────────
	if clicked_rack == selected_rack:
		_cancel_selection()
		return

	# ── KASUS 3: Ada rack terpilih → coba pindah potion ke rack ini ───────
	_try_move_to(clicked_rack)

func _try_select_rack(rack: PotionRack) -> void:
	if rack.is_empty():
		print("[DragManager] Rack %d kosong, tidak bisa dipilih" % rack.rack_id)
		return

	selected_rack = rack
	held_potion = rack.peek()           # Preview potion yang akan diambil

	# Visual feedback: rack terpilih
	rack.set_selected(true)

	# Highlight rack lain sebagai target potensial
	for other_rack in all_racks:
		if other_rack != rack:
			other_rack.set_highlighted_as_target(other_rack.can_accept(held_potion))

	# Tampilkan floating preview
	_show_floating_potion(held_potion)

	selection_changed.emit(rack)
	print("[DragManager] Pilih rack %d, potion teratas: %s" % [rack.rack_id, Potion.POTION_NAMES[held_potion.potion_type]])

func _try_move_to(target_rack: PotionRack) -> void:
	# Validasi: apakah target bisa menerima potion?
	if not target_rack.can_accept(held_potion):
		print("[DragManager] INVALID: Rack %d tidak bisa menerima potion ini" % target_rack.rack_id)
		held_potion.play_invalid_animation()
		invalid_move_attempted.emit(selected_rack, target_rack)
		return

	# Lakukan pemindahan: POP dari sumber, PUSH ke tujuan
	var from_rack = selected_rack
	var potion = selected_rack.pop()    # POP dari rack sumber

	var success = target_rack.push(potion)   # PUSH ke rack tujuan

	if success:
		potion.play_place_animation()
		move_made.emit(from_rack, target_rack, potion)
		print("[DragManager] MOVE: Rack %d → Rack %d [%s]" % [
			from_rack.rack_id,
			target_rack.rack_id,
			Potion.POTION_NAMES[potion.potion_type]
		])
	else:
		# Jika push gagal (jarang terjadi), kembalikan ke rack asal
		from_rack.push(potion)
		invalid_move_attempted.emit(selected_rack, target_rack)

	_cleanup_selection()

func _cancel_selection() -> void:
	print("[DragManager] Pilihan dibatalkan")
	_cleanup_selection()

func _cleanup_selection() -> void:
	# Reset semua highlight
	if selected_rack:
		selected_rack.set_selected(false)
	for rack in all_racks:
		rack.set_highlighted_as_target(false)

	selected_rack = null
	held_potion = null
	_hide_floating_potion()
	selection_changed.emit(null)

# ─── FLOATING VISUAL (mengikuti mouse) ───────────────────────────────────────

func _process(_delta: float) -> void:
	if held_potion and _floating_potion_display and _floating_potion_display.visible:
		# Ikuti posisi mouse
		_floating_potion_display.global_position = get_viewport().get_mouse_position() - Vector2(25, 35)

func _show_floating_potion(potion: Potion) -> void:
	if not _floating_potion_display:
		return
	_floating_potion_display.color = Potion.POTION_COLORS[potion.potion_type]
	_floating_potion_display.visible = true

func _hide_floating_potion() -> void:
	if _floating_potion_display:
		_floating_potion_display.visible = false
