extends Node

const FILE_BEGIN = "res://scenes/game_" # Replace with your next level's path!!
const FINAL_LEVEL_PATH = "res://scenes/game_3.tscn" # Replace with your final level path!!

@onready var game_started: bool = false
@onready var is_final_level: bool = false
@onready var fadeto_black: ColorRect = $Player/FadetoBlack
var start_time: float = 0.0
var is_level_finished = false # Triggered by level_finish.gd
var is_paused = false
var cannot_move = false
var alive = true


var pause_menu_scene = preload("res://scenes/options_menu.tscn")
var pause_menu: CanvasLayer # Instance of the pause menu when it's shown

# DEBUG VARIABLES. DELETE WHEN EXPORTING
var debug_mode = false
var is_invincible = false 

func _ready() -> void:
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
	if is_paused or not Gamestate.alive:
		return # If already paused, do nothing
	freeze_timer()
	Engine.time_scale = 0
	is_paused = true
	
	# Add pause scene as a child to current scene
	pause_menu = pause_menu_scene.instantiate()
	get_tree().current_scene.add_child(pause_menu)
	
	# Hide / enable proper nodes
	pause_menu.get_node("MainMenuContainer").visible = true
	pause_menu.get_node("ResetContainer").visible = true
	pause_menu.get_node("Panel").visible = false
	
func resume_game() -> void:
	if not is_paused:
		return # If already paused, do nothing
	
	# Resume timers and logic
	set_process(true)
	Engine.time_scale = 1
	is_paused = false
	
	# Hide pause menu UI
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null

func exit_to_main_menu() -> void:
	# Reset game state
	game_started = false
	is_paused = false
	is_level_finished = false
	is_final_level = false # Dont think this is needed
	Engine.time_scale = 1
	
	# Stop all music and reset volume / pitch
	Music.background_music.stop()
	Music.background_music.pitch_scale = 1.14 # Find a way to set a variable because default is not 1.0
	
	# Hide Ui and reset it
	GlobalUiTime.hide()
	
	# Change scene to the main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func reset_level() -> void:
	# Trigger fade to black !!NOT WORKING AT THE MOMENT!!
	#var fade_tween = create_tween()
	#fade_tween.tween_property(
		#fadeto_black,
		#"modulate:a", # Modify the alpha channel
		#1.0, # Fully opaque
		#1.5  
		#)
	#await fade_tween.finished
	
	# Reload the current scene
	var current_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)
	get_tree().reload_current_scene()
	
	start_time = 0
	reset()
	resume_game()

func _input(event: InputEvent) -> void:
	if game_started:
		if event.is_action_pressed("pause"):
			if is_paused:
				resume_game()
			else:
				pause_game()
	
