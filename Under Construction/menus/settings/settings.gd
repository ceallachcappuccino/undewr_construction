extends Node2D

export var main_menu : bool

#ColorRect Reference
onready var color_rect = get_node("ColorRect")
#UI Reference
onready var settings_menu_ui = get_node("SettingsMenuUI")
#Button References
onready var back_button = get_node("SettingsMenuUI/BackButton")
onready var fullscreen_check = get_node("SettingsMenuUI/FullscreenCheck")
onready var vsync_check = get_node("SettingsMenuUI/VsyncCheck")
#Slider References
onready var master_slider = get_node("SettingsMenuUI/MasterLabel/MasterVolumeSlider")
onready var music_slider = get_node("SettingsMenuUI/MusicLabel/MusicVolumeSlider")
onready var sound_slider = get_node("SettingsMenuUI/SoundLabel/SoundVolumeSlider")

var err
# Called when the node enters the scene tree for the first time.
func _ready():
	#Destroys BackButton if not needed
	if main_menu:
		color_rect.queue_free()
	else:
		back_button.queue_free()
		
	#Sets Toggles and Sliders to their current value
	fullscreen_check.set_pressed(OS.is_window_fullscreen())
	vsync_check.set_pressed(OS.is_vsync_enabled())
	
	master_slider.set_value(db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	music_slider.set_value(db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	sound_slider.set_value(db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sfx"))))
	
	#Focus on UI
	settings_menu_ui.grab_focus()
	
func _process(_delta):
	if main_menu and Input.is_action_just_pressed("ui_cancel"):
		err = get_tree().change_scene("res://menus/main_menu/main_menu.tscn")
		

#Button Functions
func _on_BackButton_pressed():
	if main_menu:
		err = get_tree().change_scene("res://menus/main_menu/main_menu.tscn")

#Checkbox Functions
func _on_VsyncCheck_toggled(button_pressed):
	OS.set_use_vsync(button_pressed)

func _on_FullscreenCheck_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)

#Slider Functions
func _on_MasterVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))

func _on_MusicVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))

func _on_SoundVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear2db(value))
