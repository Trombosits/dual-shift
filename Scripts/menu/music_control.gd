extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	var db = AudioServer.get_bus_volume_db(audio_bus_id)
	value = db_to_linear(db)

func _on_value_changed(new_value: float):
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
