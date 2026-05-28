# Potion.gd
# Representasi satu buah potion dalam gamemode FILO Sorting
# Setiap potion punya tipe/warna yang menentukan cara sortingnya
extends Node2D
class_name Potion

# TIPE/WARNA POTION
enum PotionType {RED, BLUE, GREEN, YELLOW, PURPLE}

const POTION_NAMES := {PotionType.RED: "Merah",
	PotionType.BLUE: "Biru",
	PotionType.GREEN: "Hijau",
	PotionType.YELLOW: "Kuning",
	PotionType.PURPLE: "Ungu"
}

# PATH ASSET
const POTION_TEXTURES := {
	PotionType.RED: preload("res://assets/potions/red_potion.png"),
	PotionType.BLUE: preload("res://assets/potions/blue_potion.png"),
	PotionType.GREEN: preload("res://assets/potions/green_potion.png"),
	PotionType.YELLOW: preload("res://assets/potions/yellow_potion.png"),
	PotionType.PURPLE: preload("res://assets/potions/purple_potion.png")
}

@export var potion_type: PotionType = PotionType.RED
var rack_owner = null
var _sprite: Sprite2D

func _ready() -> void:
	_build_visual()

# BUILD VISUAL
func _build_visual() -> void:
	_sprite = Sprite2D.new()
	# Pasang texture sesuai tipe
	_sprite.texture = POTION_TEXTURES[potion_type]
	# Resize sprite
	_sprite.scale = Vector2(0.10, 0.10)
	add_child(_sprite)

# GANTI TIPE POTION
func set_potion_type(new_type: PotionType) -> void:
	potion_type = new_type
	if _sprite:
		_sprite.texture = POTION_TEXTURES[potion_type]

# ANIMASI PLACE
func play_place_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)

# ANIMASI INVALID
func play_invalid_animation() -> void:
	var original_x = position.x
	var tween = create_tween()

	tween.tween_property(self, "position:x", original_x + 8, 0.05)
	tween.tween_property(self, "position:x", original_x - 8, 0.05)
	tween.tween_property(self, "position:x", original_x + 4, 0.05)
	tween.tween_property(self, "position:x", original_x, 0.05)

# HIGHLIGHT
func set_highlighted(value: bool) -> void:
	if not _sprite:
		return

	if value:
		_sprite.modulate = Color(1.3, 1.3, 1.3)
	else:
		_sprite.modulate = Color.WHITE
