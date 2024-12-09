extends Node

var config: ConfigFile = ConfigFile.new()
const DEFAULT_MASTER_VOLUME: float = 10
const CONFIG_PATH: String = "user://settings.cfg"

func _ready() -> void:
	load_config()
	set_master_volume(get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME))

func load_config() -> void:
	if config.load(CONFIG_PATH) != OK:
		push_error("Failed to load settings.cfg, creating a new one")
		config.clear()

func get_value(section: String, key: String, default_value: Variant) -> Variant:
	return config.get_value(section, key, default_value)

func set_value(section: String, key: String, value: Variant, save_now: bool = true) -> void:
	config.set_value(section, key, value)
	if save_now:
		save_config()
	
func set_master_volume(volume: float = DEFAULT_MASTER_VOLUME) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)
	set_value("audio", "master_volume", volume, false)
	
func save_config() -> void:
	var err = config.save(CONFIG_PATH)
	if err == OK:
		print ("Successfully saved %s" % CONFIG_PATH)
	else:
		push_error("Failed to save %s with error code: %d" % [CONFIG_PATH, err])
