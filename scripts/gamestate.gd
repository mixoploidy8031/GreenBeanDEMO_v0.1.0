extends Node

const FILE_BEGIN = "res://scenes/game_" # Replace with your next level's path!!
const FINAL_LEVEL_PATH = "res://scenes/game_3.tscn" # Replace with your final level path!!
const PAUSE_COOLDOWN: float = 0.25

@onready var game_started: bool = false
@onready var is_final_level: bool = false
@onready var pause_menu_scene = preload("res://scenes/options_menu.tscn")
var start_time: float = 0.0
var is_level_finished = false # Triggered by level_finish.gd
var is_paused = false
var cannot_move = false
var alive = true
var default_music_pitch: float = 1.14
var pause_menu: CanvasLayer # Instance of the pause menu when it's shown
var last_pause_time: float = 0.0
var can_pause = false

var debug_mode = false
var is_invincible = false 

func _ready() -> void:
	ConfigManager.load_config()
	set_process(false)

# Update timer based on the global GameState only if game has started
func _process(delta: float) -> void:
	if game_started and not is_final_level:
		start_time += delta
		var seconds = fmod(start_time, 60)
		var minutes = int(start_time / 60) 
		GlobalUiTime.update_timer(minutes, seconds)

# Call this when the first level is loaded
func start_game() -> void:
	if not ConfigManager.ready:
		await ConfigManager.ready
	
	# Apply the master volume right after starting the game
	var master_volume = ConfigManager.get_value("audio", "master_volume", 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	
	# Apply the music volume right after starting the game
	Music.play_game_music()
	
	can_pause = true
	game_started = true
	start_time = 0 
	set_process(true) # Start updating timer
	
	# Ensure proper timers are hidden / enabled
	if not GlobalUiTime.visible:
		GlobalUiTime.show()
	if GlobalUiTime.final_time_panel.visible:
		GlobalUiTime.final_time_panel.hide()
		
# Handle level finishing and transitioning (called by level_finish.gd)
func level_complete():
	is_level_finished = true
	Music.background_music.seek(0)
	Music.background_music.volume_db = Music.current_volume
	Music.background_music.play()
	
	#  Calculate next level path
	var current_scene_file = get_tree().current_scene.scene_file_path 
	var next_level_number = current_scene_file.to_int() + 2 # CHANGE BACK TO 1 WHEN NOT ONLY ONE LEVEL
	var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
	
	# Slow music and show final time on last level
	if next_level_path == FINAL_LEVEL_PATH:
		#game_started = false
		is_final_level = true
		freeze_timer()
		var formatted_time = "%d:%02d" % [int(start_time / 60), int(fmod(start_time, 60))]
		GlobalUiTime.show_final_message("Final Time: %s" % formatted_time)
		Music.background_music.pitch_scale = 0.95
		
	# Change to the new scene
	get_tree().change_scene_to_file(next_level_path)
	reset() # Reset timer
	
# Reset game variables
func reset():
	Engine.time_scale = 1.0
	cannot_move = false
	is_level_finished = false

# Freeze the timer for the final level
func freeze_timer() -> void:
	set_process(false)

func pause_game() -> void:
	if is_paused or not alive or (pause_menu and pause_menu != null):
		return 
	Engine.time_scale = (0.0001 ** 3)
	is_paused = true
	
	# Add pause scene as a child to current scene and hide/enable proper nodes
	pause_menu = pause_menu_scene.instantiate()
	get_tree().current_scene.add_child(pause_menu)
	pause_menu.get_node("MainMenuContainer").visible = true
	pause_menu.get_node("ResetContainer").visible = true
	pause_menu.get_node("Panel").visible = false
	
func resume_game() -> void:
	if not is_paused:
		return 
	is_paused = false
	#can_pause = true
	Engine.time_scale = 1

	
	# Hide pause menu UI
	if pause_menu:
		pause_menu.call_deferred("queue_free")
		pause_menu = null

func exit_to_main_menu() -> void:
	# Reset game state
	reset()
	can_pause = false
	game_started = false
	is_paused = false
	is_final_level = false
	#is_level_finished = false
	Engine.time_scale = 1.0
	
	# Stop all music and reset volume / pitch
	Music.background_music.stop()
	Music.background_music.pitch_scale = default_music_pitch 
	
	# Hide Ui/reset it and change to main menu
	GlobalUiTime.hide()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	ConfigManager.save_config()

func reset_level() -> void:
	# Reload the current scene
	var current_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)
	
	can_pause = true
	start_time = 0
	reset()
	resume_game()
	
	await get_tree().process_frame
	Music.background_music.stop()
	Music.background_music.seek(0)
	Music.play_game_music()

func _input(event: InputEvent) -> void:
	if game_started and alive and event.is_action_pressed("pause") and (Time.get_ticks_msec() - last_pause_time) > PAUSE_COOLDOWN * 1000:
			last_pause_time = Time.get_ticks_msec()
			if is_paused:
				resume_game()
			else:
				if can_pause:
					pause_game()
