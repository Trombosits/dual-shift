extends TextureButton
class_name SkillNode

@onready var panel = $Panel
@onready var label = $MarginContainer/Label
@onready var line_2d = $Line2D

# Tambahkan variabel ini agar kamu bisa mengatur harga tiap skill di Inspector Godot
@export var skill_cost: int = 200 

func _ready():
	if get_parent() is SkillNode:
		line_2d.add_point(global_position + size/2)
		line_2d.add_point(get_parent().global_position + size/2)

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

func _on_pressed():
	# 1. Cek apakah level belum mentok DAN poin global cukup
	if level < 3 and GlobalManager.total_skill_points >= skill_cost:
		
		# 2. Kurangi skor di GlobalManager sebagai alat pembayaran
		GlobalManager.total_skill_points -= skill_cost
		
		# 3. Naikkan level skill
		level += 1
		panel.show_behind_parent = true
		line_2d.default_color = Color(0.757, 0.769, 0.0, 1.0)
		
		# Buka kunci cabang skill selanjutnya jika level max (3)
		var skills = get_children()
		for skill in skills:
			if skill is SkillNode and level == 3:
				skill.disabled = false
				
		# 4. Beritahu scene utama untuk memperbarui tampilan teks poin di layar
		var tree_root = get_tree().current_scene
		if tree_root.has_method("update_points_display"):
			tree_root.update_points_display()
			
	elif level >= 3:
		print("Skill ini sudah level maksimal!")
	else:
		print("Skor tidak cukup! Harga: ", skill_cost, " | Skormu: ", GlobalManager.total_skill_points)
