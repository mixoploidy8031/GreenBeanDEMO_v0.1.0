extends AudioStreamPlayer2D

@onready var menu_music: AudioStreamPlayer2D = $MenuMusic
@export var background_music: AudioStreamPlayer2D
@export var default_volume: float = 0

var current_volume: float = default_volume



func _ready() -> void:
	await ConfigManager.ready
	load_volume()
	set_volume(current_volume)

func set_volume(volume: float) -> void:
	current_volume = volume
	if background_music:
		background_music.volume_db = volume
	if menu_music:
		menu_music.volume_db = volume
		
func play_game_music() -> void:
	if menu_music and menu_music.playing:
		menu_music.stop()
	if background_music:
		background_music.volume_db = current_volume
		background_music.play()
		
func play_menu_music() -> void:
	if background_music and background_music.playing:
		background_music.stop()
	if menu_music:
		menu_music.volume_db = current_volume
		menu_music.play()
		
func load_volume() -> void:
	current_volume = ConfigManager.get_value("audio", "volume", default_volume)
	set_volume(current_volume)
		
func save_volume() -> void:
	ConfigManager.set_value("audio", "volume", current_volume)
