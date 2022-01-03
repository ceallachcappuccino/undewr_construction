extends Node

onready var player = get_node("Player")
onready var animation_player = get_node("WorldAnimationPlayer")

var current_room
var next_room
var spawn_point 

# Called when the node enters the scene tree for the first time.
func _ready():
	current_room = preload("res://scenes/levels/desert_level/test_level.tscn").instance()
	add_child(current_room)
	
func load_next_room(nr, sp):
	next_room = nr
	spawn_point = sp
	animation_player.play("room_transition")
	
func room_transition():
	current_room.queue_free()
	current_room = load(next_room).instance()
	add_child(current_room)
	player.teleport(spawn_point)
	get_tree().call_group("Enemy","connect_to_player",player)
	
