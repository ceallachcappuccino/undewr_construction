extends KinematicBody2D

#common
var time = 0

#Player
var is_dead = false
var checkpoint : Vector2
onready var PlayerTween = $PlayerTween
onready var walkman = get_node("Walkman")

# Motion
var motion : Vector2
var snap : Vector2
# Horizontal
const ACCELERATION = 15
const TURN_ACCELERATION = 50
const MAX_SPEED = 165 #170
var direction : int
# Jump
const JUMP_HEIGHT = -300
var jump : bool
var on_floor : bool
# Double Jump
const DOUBLE_JUMP_HEIGHT = -225
var double_jump : bool
var wall_to_double : bool = true
# Wall Jump
var shoulder : bool = false
var on_wall : bool = false
const WALL_JUMP_HEIGHT = -300
const WALL_JUMP_WIDTH = 400
# Gravity
const GRAVITY_MAX= 600 #600
var GRAVITY = 20#38 good value
# Glide
const GLIDE_BASE_TIME = 4.0
var glide_time : float
var is_gliding : bool
var glide_drained : bool
const GLIDE = 60
const GLIDE_RE = 40
var updraft : bool
const UP_GLIDE = -150
# Visuals
var stun = false

# Room Transition
var teleporting = false
var teleport_check = false
var next_room
var spawn_point 

#SettingMenu
var settings
var settings_bool = false

func _ready():
	glide_time = GLIDE_BASE_TIME #+ GlobalRhythm.takt
	
	

func _physics_process(delta):
	time += delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		if !settings_bool:
			is_dead = true
			settings_bool = true
			settings = preload("res://menus/settings/settings.tscn").instance()
			settings.set_position(Vector2(-320,-180))
			add_child(settings)
		else:
			is_dead = false
			settings_bool = false
			settings.queue_free()
		
		
	if !is_dead:
		snap = Vector2.DOWN
		
		if (!is_gliding and !on_wall) or (on_wall and motion.y <= 0):
			motion.y = min(motion.y + GRAVITY, GRAVITY_MAX)
		
		if is_on_floor() and !on_floor:
			motion.y = 0
			set_on_floor()
		
		if !shoulder:
			on_wall = false
				
		# Right Move
		if Input.is_action_pressed('ui_right'):
			direction = 1
			if motion.x < 0:
				motion.x += TURN_ACCELERATION
			else:
				motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
			$PlayerVisuals/PlayerAnimation.set_flip_h(false)
			$PlayerVisuals/PlayerAnimation.play("run")
			$PlayerVisuals/Effects/ShoulderParticles.set_position(Vector2(7,3))	
		# Left Moved
		elif Input.is_action_pressed('ui_left'):
			direction = -1
			if motion.x > 0:
				motion.x -= TURN_ACCELERATION
			else:
				motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
			$PlayerVisuals/PlayerAnimation.set_flip_h(true)
			$PlayerVisuals/PlayerAnimation.play("run")
			$PlayerVisuals/Effects/ShoulderParticles.set_position(Vector2(-7,3))
		# Bremst den Character auf null, falls kein Rechts oder Linsk Input erfolgt
		else:
			$PlayerVisuals/PlayerAnimation.play("idle")
			if motion.x > 0:
				motion.x = max(0, motion.x - 15)
			elif motion.x < 0:
				motion.x = min(0, motion.x + 15)
	
		# Simple Jump
		if Input.is_action_just_pressed("jump"):
			set_jump()
			
			
		if on_floor:
			double_jump = true
			glide_time = min(glide_time + 5*delta, GLIDE_BASE_TIME )#+ GlobalRhythm.takt)
			if jump:
				motion.y = JUMP_HEIGHT
				jump = false
				on_floor = false
	
		# Wall Jump
		if !on_floor and shoulder and motion.y > 0 and Input.is_action_pressed("wallslide"): ###
			is_gliding = false
			$PlayerVisuals/Effects/ShoulderParticles.set_lifetime(0.5)
			$PlayerVisuals/Effects/ShoulderParticles.set_emitting(true)
			if !on_wall:
				on_wall = true
				motion.y = 1
			motion.y = min(motion.y + 0.3, 100)
			$PlayerVisuals/PlayerAnimation.play("wall_slide")
			if jump:
				wall_to_double_offset()
				motion = Vector2(-direction * WALL_JUMP_WIDTH, WALL_JUMP_HEIGHT)
				direction *= -1
				$PlayerVisuals/Effects/ShoulderParticles.set_position(Vector2(($PlayerVisuals/Effects/ShoulderParticles.get_position().x) * -1,3))	
				$PlayerVisuals/PlayerAnimation.set_flip_h(!$PlayerVisuals/PlayerAnimation.is_flipped_h())
		else:
			on_wall = false
			$PlayerVisuals/Effects/ShoulderParticles.set_lifetime(0.01)
			$PlayerVisuals/Effects/ShoulderParticles.set_emitting(false)
		
		# Double Jump
		if !on_floor and !is_gliding and !shoulder: ###
			$PlayerVisuals/PlayerAnimation.play("jump")
			if jump and double_jump and !on_wall and wall_to_double:
				motion.y = DOUBLE_JUMP_HEIGHT
				double_jump = false
				
		# Glide
		if updraft:
			if Input.is_action_pressed("glide") and glide_time > 0 and !glide_drained:
				is_gliding = true
				motion.y = max(motion.y - GLIDE_RE, UP_GLIDE)
				glide_time = max(glide_time - delta, 0)
				$PlayerVisuals/PlayerAnimation.play("glide")
			else:
				is_gliding = false
		else:
			if Input.is_action_pressed("glide") and !on_floor and motion.y > 0 and glide_time > 0 and !on_wall and !glide_drained:
				is_gliding = true
				motion.y = max(motion.y - GLIDE_RE,GLIDE)
				glide_time = max(glide_time - delta, 0)
				$PlayerVisuals/PlayerAnimation.play("glide")
			else:
				is_gliding = false
			
		if Input.is_action_pressed("gravity"):
			GRAVITY = 10
			set_material(load("res://new_shadermaterial.material"))
		
		
		if Input.is_action_just_pressed("shockwave"):
			$PlayerAnimationPlayer.play("shockwave")
			$PlayerVisuals/Effects/Shockwave.set_emitting(true)
			
		#Room Transition
		if teleporting and on_floor and !teleport_check:
			teleport_check = true
			yield(get_tree().create_timer(1.0), "timeout")
			if teleporting and on_floor:
				room_transition()
			teleport_check = false
		
		motion = move_and_slide_with_snap(motion, snap, Vector2.UP)
		 
		#Dying
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				#if "Death" in get_slide_collision(i).collider.name:
				if get_slide_collision(i) in get_tree().get_nodes_in_group("Enemy"):
					death()
			
		#Visuals
		#Time Diletation
		if motion.y > 0 and motion.y <= 600:
			$PlayerVisuals.set_global_scale(Vector2((-0.18/pow(600, 2))*pow(motion.y,2)+1, 
			(0.18/pow(600, 2))*pow(motion.y,2)+1))
			$PlayerCollision.set_global_scale(Vector2((-0.18/pow(600, 2))*pow(motion.y,2)+1,1))
		else:
			$PlayerVisuals.set_global_scale(Vector2(1,1)) 
			$PlayerCollision.set_global_scale(Vector2(1,1))
		
		#High Fall Stun
		if motion.y >= GRAVITY_MAX and !stun:
			stun = true
			yield(get_tree().create_timer(0.1), "timeout")
			stun = false
		if stun and is_on_floor():
			is_dead = true
#			$AnimationPlayer.play("canvas_stun")
			$PlayerVisuals/PlayerAnimation.play("idle")
			$PlayerVisuals/Effects/HighDropStun.set_emitting(true)
			$PlayerAnimationPlayer.play("fall_stun")
			yield(get_tree().create_timer(1.0), "timeout")
			is_dead = false
			stun = false

func death():
	is_dead = true
	teleport(checkpoint)
	
func room_transition():
	is_dead = true
	owner.load_next_room(next_room,get_position())# spawn_point)
	
func set_jump():
	jump = true
	snap = Vector2.ZERO
	yield(get_tree().create_timer(0.1), "timeout")
	jump = false

func set_on_floor():
	on_floor = true
	yield(get_tree().create_timer(0.3), "timeout")
	on_floor = false

func wall_to_double_offset():
	wall_to_double = false
	yield(get_tree().create_timer(0.1), "timeout")
	wall_to_double = true

# Area Checks
func _on_PlayerArea_area_entered(area):
	if "Checkpoint" in area.name:
		checkpoint = area.get_global_position()
	if "Updraft" in area.name:
		updraft = true
	if "Cassette" in area.name:
		walkman.playlist.append([area.owner.audio, area.owner.bpm, area.owner.beats, area.owner.title])
		#CurrentSave.tracks.append(area.owner.title)
		pass
	if "StaminaPowerUp" in area.name:
		pass
#		glide_time = GLIDE_BASE_TIME + GlobalRhythm.takt
	if "GlideDrain" in area.name:
		if !glide_drained:
			glide_drained = true
			is_gliding = false
			$PlayerVisuals/Effects/GlideDrain.restart()
	if "GlideRestore" in area.name:
		if glide_drained:
			glide_drained = false
			$PlayerVisuals/Effects/GlideRestore.restart()
	if "Jumpo" in area.name:
		motion.y = -motion.y +1		
	if "Teleporter" in area.name:
		teleporting = true
		next_room = area.next_room
		spawn_point = area.spawn_point
	

func _on_PlayerArea_area_exited(area):
	if "Updraft" in area.name:
		updraft = false
	if "Teleporter" in area.name:
		teleporting = false
		
#Slides the Player to Point
func teleport(point):
	motion = Vector2.ZERO
	is_gliding = false
	glide_drained = false

#	glide_time = GLIDE_BASE_TIME + GlobalRhythm.takt
#	$AnimationPlayer.play("death")
	$PlayerVisuals/PlayerAnimation.play("idle")
	$PlayerCollision.set_deferred("disabled", true)
	$Areas/PlayerArea/PlayerAreaShape.set_deferred("disabled", true)
	
	PlayerTween.interpolate_property(self, "position", get_global_position(), point, 0.4,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	PlayerTween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	
	$PlayerCollision.set_deferred("disabled", false)
	$Areas/PlayerArea/PlayerAreaShape.set_deferred("disabled", false)
	
	is_dead = false
	
	
func _on_Shoulder_body_entered(body):
	if !("Player" in body.name):
		shoulder = true
	
func _on_Shoulder_body_exited(body):
	if !("Player" in body.name):
		shoulder = false

func _on_PlayerArea_body_entered(body):
	if "Death"in body.name:
		is_dead = true
		teleport(checkpoint)

func _on_ShockwaveArea_body_entered(body):
	if "Death" in body.name:
		body.shock()
