extends AnimatedSprite


var level_stops = [0,20,40]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("glide"):
		set_frame(get_frame()+1)
		play()
		
	if get_frame() in level_stops:
		stop()
		
	
