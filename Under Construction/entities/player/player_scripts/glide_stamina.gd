extends TextureProgress
var stamina : float
var alpha : float
var x : float
onready var player = get_parent().get_parent()


func _ready():
	modulate.a = 0
	x = 2
	set_max(player.GLIDE_BASE_TIME)# + #GlobalRhythm.takt)
	
func _physics_process(delta):
	set_max(player.GLIDE_BASE_TIME)# + GlobalRhythm.takt)
	stamina = player.glide_time
	set_value(stamina)
	
	if player.is_gliding:
		modulate.a = min(modulate.a + 2.5 * delta, 1)
		x = 0
	else:
		x = min(x + delta, 2)
		alpha = - pow(0.5 * x, 4) + 1
		modulate.a = max(0, alpha)
		
