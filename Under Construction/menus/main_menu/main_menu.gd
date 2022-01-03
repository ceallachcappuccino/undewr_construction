extends Node

export var settings_menu : String
export var world : String

var err

func _ready():
	$UI.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_SettingsButton_pressed():
	err = get_tree().change_scene(settings_menu)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_NewGameButton_pressed():
	err = get_tree().change_scene(world)
