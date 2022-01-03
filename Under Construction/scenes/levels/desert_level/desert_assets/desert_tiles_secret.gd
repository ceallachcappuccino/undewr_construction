extends TileMap

var inside = false

func _ready():
	modulate.a = 1
	
func _process(delta):
	if inside:
		modulate.a = max(0.7, modulate.a - 1 * delta)
	else:
		modulate.a = min(1, modulate.a + 0.4 * delta)

func _on_SecretArea_area_entered(area):
	if "Player" in area.name:
		inside = true

func _on_SecretArea_area_exited(area):
	if "Player" in area.name:
		inside = false
		


