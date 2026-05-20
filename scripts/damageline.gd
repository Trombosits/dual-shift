extends Area2D

# Sinyal kustom kita
signal line_breached

func _ready():
	# Kita hubungkan sinyal bawaan Area2D ke fungsi kita lewat kode
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Fungsi ini HANYA akan dipanggil sekali saat ada musuh menyentuh garis
	line_breached.emit()
