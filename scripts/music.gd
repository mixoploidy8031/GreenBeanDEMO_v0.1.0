extends AudioStreamPlayer2D

@onready var menu_music: AudioStreamPlayer2D = $MenuMusic
@onready var background_music: AudioStreamPlayer2D = $"."
@onready var current_volume: float = ConfigManager.get_value("audio", "music_volume", 0)

var volume_dirty = false # Tracks when volume level is changed by user

func _ready() -> void:
	if not Engine.is_editor_hint():
		#await ConfigManager.ready
		load_volume()
		set_volume(current_volume)

# Play the background music (can be called from GameState)
func play_game_music() -> void:
	if menu_music and menu_music.playing:
		menu_music.stop()
	if background_music and not background_music.playing:
		set_volume(current_volume)
		background_music.play()

func play_menu_music() -> void:
	if background_music and background_music.playing:
		background_music.stop()
	if menu_music:
		set_volume(current_volume)
		menu_music.play()
		print ("[Music] Playing menu music. Volume:", current_volume)
		
func load_volume() -> void:
	current_volume = ConfigManager.get_value("audio", "music_volume", 0)
	if current_volume < -80:
		current_volume = 0
	set_volume(current_volume)
	print ("Music Volume:", current_volume)

func set_volume(volume: float) -> void:
	if volume != null and volume != current_volume:
		current_volume = volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)
		if background_music:
			background_music.volume_db = current_volume
		if menu_music:
			menu_music.volume_db = current_volume
		print ("[Music] Current volume is: ", current_volume)

func save_volume() -> void:
	print ("[Music] Saving volume to config. Current Volume:", current_volume)
	ConfigManager.set_value("audio", "volume", current_volume)
	ConfigManager.save_config()
