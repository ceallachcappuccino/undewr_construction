extends Node


func _process(_delta):
	if Input.get_last_mouse_speed() > Vector2.ZERO:
		Input.set_mouse_mode(0)

func _input(event):
	if event is InputEventKey:
		Input.set_mouse_mode(1)
