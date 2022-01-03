extends AudioStreamPlayer2D


export var audio : AudioStream
export var bpm : float
export var beats : float
export var title : String

onready var cassette_animation = get_node("CassetteAnimation")

func _ready():
	set_stream(audio)
	play()
	cassette_animation.play("default_animation")
	
	if title in CurrentSave.tracks:
		queue_free()

func _on_Cassette_finished():
	play()
	print("cass")

func _on_CassetteArea_area_entered(area):
	if "Player" in area.name:
		print(area.name)
		cassette_animation.play("collected")
