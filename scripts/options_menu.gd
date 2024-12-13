extends CanvasLayer

@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var button_sound: AudioStreamPlayer2D = $"Button Sound"
@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/VolumeSlider
@onready var confirmation_dialog: ConfirmationDialog = $MainMenuContainer/ConfirmationDialog
@onready var reset_level: Button = $ResetContainer/ResetLevel
@onready var back: Button = $BackMarginContainer/Back

func _on_ready() -> void:
	# Ensure ConfigManager is ready before loading sliders
	if not ConfigManager.is_connected("ready", Callable(self, "_on_config_ready")):
		ConfigManager.connect("ready", Callable(self, "_on_config_ready"))

	# If ConfigManager is already ready, call it now
	if ConfigManager.config:
		_on_config_ready()

# Load slider values from config and apply them
func _on_config_ready() -> void:
	print ("[OptionsMenu] Config is ready. Loading volumes...")
	var music_volume = ConfigManager.get_value("audio", "music_volume", 0)
	Music.set_volume(music_volume)
	music_slider.value = music_volume
	master_slider.value = ConfigManager.get_value("audio", "master_volume", 0)

func _on_back_pressed() -> void:
	back.disabled = true
	if not Gamestate.is_paused:
		button_sound.play()
		await button_sound.finished
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	else:
		button_sound.play()
		await button_sound.finished
		Gamestate.resume_game()

func _on_reset_level_pressed() -> void:
	reset_level.disabled = true
	button_sound.play()
	await button_sound.finished
	Gamestate.reset_level()

func _on_main_menu_pressed() -> void: 
	button_sound.play()
	confirmation_dialog.popup_centered()

func _on_confirmation_yes_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	Gamestate.exit_to_main_menu()

func _on_confirmation_no_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	confirmation_dialog.hide()

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

func _on_master_slider_drag_ended(value_changed: bool) -> void:
	print ("[OptionsMenu] Slider drag ended. Marking volume as dirty and saving config")
	var volume = master_slider.value
	ConfigManager.set_value("audio", "master_volume", volume)
	ConfigManager.save_config()

func _on_music_slider_value_changed(value: float) -> void:
	Music.set_volume(value)

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	var volume = music_slider.value
	Music.set_volume(volume)
	ConfigManager.set_value("audio", "music_volume", volume)
	ConfigManager.save_config()
	print ("[OptionsMenu] Music Volume set to:", volume)
