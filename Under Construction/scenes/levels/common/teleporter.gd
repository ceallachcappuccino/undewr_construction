extends Area2D

export var next_room : String
export var spawn_point : Vector2

func _ready():
	$TeleporterParticle.set_lifetime(0.3)
	$TeleporterParticle.set_amount(40)


func _on_Teleporter_area_entered(area):
	if "Player" in area.name:
		$TeleporterParticle.set_lifetime(1.5)
		$TeleporterParticle.set_amount(120)

func _on_Teleporter_area_exited(area):
	if "Player" in area.name:
		$TeleporterParticle.set_lifetime(0.3)
		$TeleporterParticle.set_amount(40)
