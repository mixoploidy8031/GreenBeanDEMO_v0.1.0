extends CanvasLayer

@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var button_sound: AudioStreamPlayer2D = $"Button Sound"
@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/VolumeSlider
@onready var fullscreen_checkbox: Button = $Panel/MarginContainer/FullscreenCheckbox
@onready var confirmation_dialog: ConfirmationDialog = $MainMenuContainer/ConfirmationDialog

func _on_ready() -> void:
	# Load and apply the saved volumes for the Master and Music sliders
	load_master_volume()
	master_slider.value = AudioServer.get_bus_volume_db(MASTER_BUS)
	
	load_music_volume()
	music_slider.value = Music.current_volume
	
func _on_back_pressed() -> void:
	if not Gamestate.is_paused:
		button_sound.play()
		await button_sound.finished
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	else:
		button_sound.play()
		await button_sound.finished
		Gamestate.resume_game()

# ADD CODE TO RESET LEVEL
func _on_reset_level_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	Gamestate.reset_level()

func _on_main_menu_pressed() -> void: 
	button_sound.play()
	confirmation_dialog.popup_centered()

func _on_confirmation_yes_pressed() -> void:
	#Music.background_music.stop()
	button_sound.play()
	await button_sound.finished
	Gamestate.exit_to_main_menu()

func _on_confirmation_no_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	confirmation_dialog.hide()

func _on_music_slider_value_changed(value: float) -> void:
	if Music:
		Music.set_volume(value)
		Music.save_volume()
	
func _on_master_slider_value_changed(value: float) -> void:
	set_master_volume(value)
	save_master_volume(value)
		
func set_master_volume(volume: float) -> void:
	# Set master bus volume using the value from the slider
	AudioServer.set_bus_volume_db(MASTER_BUS, volume)
	 
func save_master_volume(volume: float) -> void:
	ConfigManager.set_value("audio", "master_volume", volume)

func load_master_volume() -> void:
	var volume = ConfigManager.get_value("audio", "master_volume", 0.0)
	set_master_volume(volume)
		
func load_music_volume() -> void:
	# Load and apply the saved music volume from Music.gd
	Music.load_volume()
