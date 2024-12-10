extends Node

const FILE_BEGIN = "res://scenes/game_" # Replace with your next level's path!!
const FINAL_LEVEL_PATH = "res://scenes/game_3.tscn" # Replace with your final level path!!

@onready var game_started: bool = false
var start_time: float = 0.0
var is_level_finished = false # Triggered by level_finish.gd
var is_paused = false
var cannot_move = false
var alive = true


# DEBUG VARIABLES. DELETE WHEN EXPORTING
var debug_mode = false
var is_invincible = false 

func _ready() -> void:
	set_process(false)

# Update timer based on the global GameState only if game has started
func _process(delta: float) -> void:
	if game_started:
		start_time += delta
		var seconds = fmod(start_time, 60)
		var minutes = int(start_time / 60) 
		GlobalUiTime.update_timer(minutes, seconds)

# Call this when the first level is loaded
func start_game() -> void:
	Music.background_music.volume_db = Music.current_volume
	Music.background_music.play()
	game_started = true
	start_time = 0 
	set_process(true) # Start updating timer

# Handle level finishing and transitioning (called by level_finish.gd)
func level_complete():
	is_level_finished = true
	
	# Reset music volume and start playing again
	Music.background_music.seek(0)
	Music.background_music.volume_db = Music.current_volume
	Music.background_music.play()
	
	#  Calculate next level path
	var current_scene_file = get_tree().current_scene.scene_file_path 
	var next_level_number = current_scene_file.to_int() + 1
	var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
	
	if next_level_path == FINAL_LEVEL_PATH:
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
	game_started = false
	set_process(false)
	
func pause_game() -> void:
	if is_paused:
		return # If already paused, do nothing
	freeze_timer()
	get_tree().paused = true
	is_paused = true
	# Show pause menu UI
	var pause_menu = load("res://scenes/options_menu.tscn").instantiate()
	#pause_menu.get_node("")
	
