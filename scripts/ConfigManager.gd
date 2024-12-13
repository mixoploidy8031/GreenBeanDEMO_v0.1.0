extends Node

const DEFAULT_MASTER_VOLUME: float = 0
const DEFAULT_MUSIC_VOLUME: float = 0
const CONFIG_PATH: String = "user://settings.cfg"

var config: ConfigFile = ConfigFile.new()
var volume_dirty = false

func _ready() -> void:
	print ("[ConfigManager] _ready() called, loading config...")
	load_config()
	emit_signal("ready")
	print ("[ConfigManager] Config is ready")
	
	# Apply master volume from the config on game start
	var master_volume = get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	
	# Apply music volume from the config on game start
	var music_volume = get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	Music.set_volume(music_volume)

# Loads configuration file or creates a new one if it doesn't exist
func load_config() -> void:
	if config.load(CONFIG_PATH) != OK:
		push_error("Failed to load settings.cfg, creating a new one")
		config.clear()

# Get a value from the configuration file, returning a defualt if the key doesn't exist
func get_value(section: String, key: String, default_value: Variant) -> Variant:
	return config.get_value(section, key, default_value)

# Set a value in the config file and check if changed (volume_dirty)
func set_value(section: String, key: String, value: Variant) -> void:
	var current_value = config.get_value(section, key, null)
	if current_value != value:
		config.set_value(section, key, value)

# Save configuration to disk
func save_config() -> void:
	var err = config.save(CONFIG_PATH)
	if err == OK:
		print ("Successfully saved %s" % CONFIG_PATH)
	else:
		push_error("Failed to save %s with error code: %d" % [CONFIG_PATH, err])
