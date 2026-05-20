# Potion.gd
# Representasi satu buah potion dalam gamemode FILO Sorting
# Setiap potion punya tipe/warna yang menentukan cara sortingnya
extends Node2D
class_name Potion

# ─── KONSTANTA TIPE POTION ──────────────────────────────────────────────────
enum PotionType {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE
}

# Warna placeholder untuk setiap tipe (diganti asset nanti)
const POTION_COLORS: Dictionary = {
	PotionType.RED:    Color(0.9, 0.2, 0.2),
	PotionType.BLUE:   Color(0.2, 0.4, 0.9),
	PotionType.GREEN:  Color(0.2, 0.8, 0.3),
	PotionType.YELLOW: Color(0.9, 0.85, 0.1),
	PotionType.PURPLE: Color(0.6, 0.1, 0.9),
}

const POTION_NAMES: Dictionary = {
	PotionType.RED:    "Merah",
	PotionType.BLUE:   "Biru",
	PotionType.GREEN:  "Hijau",
	PotionType.YELLOW: "Kuning",
	PotionType.PURPLE: "Ungu",
}

# ─── PROPERTI ────────────────────────────────────────────────────────────────
@export var potion_type: PotionType = PotionType.RED
@export var potion_size: Vector2 = Vector2(50, 70)

var is_dragging: bool = false
var original_position: Vector2 = Vector2.ZERO
var rack_owner: Node = null          # Rack tempat potion ini berada

# Node referensi (dibuat manual karena belum ada asset)
var _body: ColorRect
var _label: Label

# ─── LIFECYCLE ───────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_placeholder_visual()

# ─── MEMBANGUN VISUAL PLACEHOLDER ────────────────────────────────────────────
func _build_placeholder_visual() -> void:
	# Body potion (kotak berwarna sebagai placeholder)
	_body = ColorRect.new()
	_body.size = potion_size
	_body.position = -potion_size / 2   # Center pivot
	_body.color = POTION_COLORS[potion_type]
	add_child(_body)

	# Label tipe (untuk debugging dan readability)
	_label = Label.new()
	_label.text = POTION_NAMES[potion_type][0]  # Huruf pertama saja
	_label.position = _body.position + Vector2(10, 20)
	_label.add_theme_font_size_override("font_size", 20)
	add_child(_label)

# ─── PUBLIC API ──────────────────────────────────────────────────────────────

## Mengubah tipe potion dan memperbarui visual
func set_potion_type(new_type: PotionType) -> void:
	potion_type = new_type
	if _body:
		_body.color = POTION_COLORS[potion_type]
	if _label:
		_label.text = POTION_NAMES[potion_type][0]

## Animasi bounce saat berhasil ditaruh
func play_place_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

## Animasi shake saat gerakan tidak valid
func play_invalid_animation() -> void:
	var original_x = position.x
	var tween = create_tween()
	tween.tween_property(self, "position:x", original_x + 8, 0.05)
	tween.tween_property(self, "position:x", original_x - 8, 0.05)
	tween.tween_property(self, "position:x", original_x + 4, 0.05)
	tween.tween_property(self, "position:x", original_x, 0.05)

## Highlight potion saat di-hover
func set_highlighted(value: bool) -> void:
	if _body:
		if value:
			_body.color = POTION_COLORS[potion_type].lightened(0.3)
		else:
			_body.color = POTION_COLORS[potion_type]
