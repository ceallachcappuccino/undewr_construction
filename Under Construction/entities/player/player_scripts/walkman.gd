extends AudioStreamPlayer

export var change_tape_sound : AudioStream
export var rewind_tape_sound : AudioStream

var playlist = [] #track(audio,bpm,beats,title)
var is_playlist_empty = true
var track_number : int
var is_changing_tape : bool
var is_playing : bool

var err

func _process(_delta):
	if playlist.size() > 0 and is_playlist_empty:
		is_playlist_empty = false
		track_number = randi()%playlist.size()
		play_track(playlist[track_number], 1)
		
	if Input.is_action_just_pressed("next_tape") and !is_changing_tape:
		next_tape()
		
	if Input.is_action_just_pressed("rewind_tape") and !is_changing_tape:
		rewind_tape()

func rewind_tape():
	is_playing = false
	play_track(playlist[track_number], 0)
	Rhythm.stop_tick()
	
func next_tape():
	is_playing = false
	play_track(playlist[(track_number + 1) % playlist.size()],1)
	Rhythm.stop_tick()

func play_track(track, type):
	is_changing_tape = true
	stop()
	
	#Choosing rewind or next
	if type == 0:
		set_stream(rewind_tape_sound)
	elif type == 1:
		set_stream(change_tape_sound)
		
	play()
	yield(get_tree().create_timer(get_stream().get_length()), "timeout")
	stop()
	is_changing_tape = false
	
	Rhythm.interval = (60.0 * track[2])/track[1]
	set_stream(track[0])
	is_playing = true
	play()
	print("restart")
	Rhythm.start_tick()

func start_track():
	Rhythm.stop_tick()
	play()
	print("restart")
	Rhythm.start_tick()

func _on_Walkman_finished():
#	if is_playing:
#		start_track()
	pass
		
