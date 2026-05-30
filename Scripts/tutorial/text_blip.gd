extends AudioStreamPlayer

const sounds : Dictionary = {
	"female": preload("res://assets/sfx/sfx-blipfemale.wav"),
	"male": preload("res://assets/sfx/sfx-blipmale.wav")
}

func play_sound(character_details: Dictionary):
	var character_gender = character_details["gender"]

	stream = sounds[character_gender]

	stop()
	play()
