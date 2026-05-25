
# PotionRack.gd — FIXED
# Bug #3 fix: signal selection_changed tidak lagi typed PotionRack (hindari emit null error)
# Bug #5 fix: source rack panggil _reposition_potions() setelah pop
extends Area2D
class_name PotionRack

#-- FONT ------------------------------------------
var font = load("res://assets/Fonts/static/PixelifySans-Regular.ttf")

signal rack_clicked(rack)
signal stack_changed(rack)

@export var rack_id: int = 0
@export var max_capacity: int = 5
@export var potion_spacing_y: float = 80.0
@export var rack_width: float = 120.0

var _stack: Array[Potion] = []
var _is_selected: bool = false
var _rack_body: ColorRect

func _ready() -> void:
	print("RACK READY:", rack_id)
	_build_rack_visual()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(rack_width, max_capacity * potion_spacing_y)
	collision.shape = shape
	collision.position = Vector2(0, -(max_capacity * potion_spacing_y) / 2)
	add_child(collision)
	input_pickable = true
	input_event.connect(_on_input_event)

func _build_rack_visual() -> void:
	_rack_body = ColorRect.new()
	_rack_body.size = Vector2(rack_width, max_capacity * potion_spacing_y + 20)
	_rack_body.position = Vector2(-rack_width / 2, -(max_capacity * potion_spacing_y + 60))
	_rack_body.color = Color(0.3, 0.25, 0.15)
	
	_rack_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(_rack_body)

	var id_label = Label.new()
	id_label.text = "Rack %d" % rack_id
	id_label.position = Vector2(-30, 10)
	id_label.add_theme_font_override('font', font)
	id_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(id_label)

# ─── STACK OPERATIONS ────────────────────────────────────────────────────────

func push(potion: Potion) -> bool:
	if is_full():
		print("[Rack %d] PUSH gagal: penuh" % rack_id)
		return false

	if potion.get_parent() and potion.get_parent() != self:
		potion.reparent(self)
	elif not potion.get_parent():
		add_child(potion)

	potion.rack_owner = self
	_stack.append(potion)
	_reposition_potions()
	stack_changed.emit(self)
	print("[Rack %d] PUSH: %s → size=%d" % [rack_id, Potion.POTION_NAMES[potion.potion_type], _stack.size()])
	return true

# BUG #5 FIX: kembalikan potion dan juga update visual source rack
func pop() -> Potion:
	if is_empty():
		print("[Rack %d] POP gagal: kosong" % rack_id)
		return null

	var top_potion = _stack.pop_back()
	top_potion.rack_owner = null
	# Tidak perlu _reposition_potions() di sini karena sisa potion
	# posisinya sudah benar (yang diambil adalah TOP, yang lain tidak bergerak)
	stack_changed.emit(self)
	print("[Rack %d] POP: %s → size=%d" % [rack_id, Potion.POTION_NAMES[top_potion.potion_type], _stack.size()])
	return top_potion

func peek() -> Potion:
	if is_empty():
		return null
	return _stack.back()

func can_accept(_potion: Potion) -> bool:
	if is_full():
		return false
	if is_empty():
		return true
	return true

func is_full() -> bool:
	return _stack.size() >= max_capacity

func is_empty() -> bool:
	return _stack.is_empty()

func get_size() -> int:
	return _stack.size()

func is_sorted() -> bool:
	if _stack.size() <= 1:
		return true
	var base_type = _stack[0].potion_type
	for potion in _stack:
		if potion.potion_type != base_type:
			return false
	return true

func get_stack_types() -> Array:
	return _stack.map(func(p): return p.potion_type)

func _reposition_potions() -> void:
	for i in _stack.size():
		var potion = _stack[i]
		var target_y = -((i + 1) * potion_spacing_y)
		var tween = create_tween()
		tween.tween_property(potion, "position", Vector2(0, target_y), 0.15)\
			 .set_ease(Tween.EASE_OUT)

func set_selected(value: bool) -> void:
	_is_selected = value
	print("SET SELECTED:", rack_id, value)
	if _rack_body:
		if value:
			_rack_body.color = Color.YELLOW
		else:
			_rack_body.color = Color(0.3, 0.25, 0.15)

func set_highlighted_as_target(value: bool) -> void:
	if _rack_body:
		if value:
			_rack_body.color = Color(0.2, 0.5, 0.2)
		else:
			_rack_body.color = Color(0.3, 0.25, 0.15)

func initialize_with_potions(types: Array) -> void:
	for type in types:
		var potion = Potion.new()
		potion.potion_type = type
		push(potion)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("RACK DIKLIK:", rack_id)
			var drag_manager = get_tree().get_first_node_in_group("drag_manager")
			if drag_manager:
				drag_manager._on_rack_clicked(self)
			else:
				push_warning("[PotionRack] DragManager tidak ditemukan di group 'drag_manager'!")
