extends Node

signal tick()

var ticking : bool
var interval = 0.0

var err

func start_tick():
	ticking = true
	while ticking:
		emit_signal("tick")
		yield(get_tree().create_timer(interval), "timeout")

func stop_tick():
	ticking = false

func connect_to_rhythm(object):
	err = connect("tick",object,"_on_tick")
