extends Node

onready var active = $PurpleRhythmActive
onready var anim = $PurpleRhythmPlayer

var purple : bool
var inside : bool

func _ready():
	#Connection to Rhythm Signal
	Rhythm.connect_to_rhythm(self)
	
	#Default Yellow active, Purple inactive
	purple = false
	active.set_visible(false)
	#active.set_modulate(Color(1,1,1,0))
	active.set_collision_layer_bit(0, 0)
	active.set_collision_mask_bit(0, 0)

func _on_PurpleArea_area_entered(area):
	if "Player" in area.name:
		inside = true

func _on_PurpleArea_area_exited(area):
	if "Player" in area.name:
		inside = false
		if purple:
			active.set_visible(true)
			#anim.play("fade_in")
			active.set_collision_layer_bit(0, 1)
			active.set_collision_mask_bit(0, 1)

func _on_tick():
	if !purple:
		purple = true
		if !inside:
			active.set_visible(true)
			#anim.play("fade_in")
			active.set_collision_layer_bit(0, 1)
			active.set_collision_mask_bit(0, 1)
	else:
		purple = false
		active.set_visible(false)
		#anim.play("fade_out")
		active.set_collision_layer_bit(0, 0)
		active.set_collision_mask_bit(0, 0)


