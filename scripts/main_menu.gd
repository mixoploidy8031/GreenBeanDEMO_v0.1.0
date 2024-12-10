extends Control

@export var tween_intensity: float
@export var tween_duration: float
@onready var play: Button = $VBoxContainer/Play
@onready var options: Button = $VBoxContainer/Options
@onready var quit: Button = $VBoxContainer/Quit
@onready var button_sound: AudioStreamPlayer2D = $"Button Sound"
@onready var start_sound: AudioStreamPlayer2D = $StartSound
@onready var fadeto_black: ColorRect = $FadetoBlack
@onready var playtimer: Timer = $Timers/Playtimer
@onready var titlename: CanvasLayer = $titlename
@onready var animation_player: AnimationPlayer = $VBoxContainer/TitleReal/AnimationPlayer

var timer_duration: float = 2.5

func _on_ready() -> void:
	if not Music.menu_music.playing:
		Music.menu_music.play()

func _on_start_pressed() -> void:
	# Called when clicking play
	Music.menu_music.stop()
	start_sound.play()
	playtimer.start(timer_duration)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(
		fadeto_black,
		"modulate:a", # Modify the alpha channel
		1.0, # Fully opaque
		2.0  # Fade duration 
	)
	animation_player.play("shake")

func _on_playtimer_timeout() -> void:
	Gamestate.start_game()
	get_tree().change_scene_to_file("res://scenes/game1.tscn")
	

func _on_options_pressed() -> void:
	button_sound.play()
	await button_sound.finished
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
