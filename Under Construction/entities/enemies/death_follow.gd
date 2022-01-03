extends KinematicBody2D

onready var player = get_tree().get_root().get_node("World/Player")
#var player
onready var default_position = get_position()
var motion : Vector2
var velocity = 0
const max_velocity = 120
const acceleration = 3
#var player
var follow = false
var shocking = false
var returning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func _physics_process(_delta):
	if follow and !returning:
		velocity = min(velocity + acceleration,max_velocity)
		motion = ((player.get_global_position() + Vector2(0,8)) - get_position()).normalized() * velocity
	else:
		if default_position.distance_to(get_position()) < 10:
			motion = Vector2.ZERO
			velocity = 0
			returning = false
		else:
			velocity = min(velocity + acceleration,max_velocity)
			motion = (default_position - get_position()).normalized() * 80
	
	motion = move_and_slide(motion, Vector2.UP)
	
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			#if get_slide_collision(i) in get_tree().get_nodes_in_group("Player"):
			if "Player" in get_slide_collision(i).collider.name:
				follow = false
				returning = true
				player.death()

func shock():
	velocity = 0
	#motion = ((get_position() - player.get_global_position()).normalized()) * 800
	motion = ((get_position() - player.get_global_position()).normalized()) * (200.0*200.0/(player.get_global_position().distance_to(get_position())))
	motion = move_and_slide(motion, Vector2.UP)

func _on_DetectionArea_area_entered(area):
	if "Player" in area.name:
		velocity = 0
		follow = true

func _on_DetectionArea_area_exited(area):
	if "Player" in area.name:
		follow = false

func connect_to_player(p):
	player = p
