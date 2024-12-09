extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var timer: Timer = $Timer
@onready var finish_sound: AudioStreamPlayer2D = $LevelFinishSound
@onready var fadeto_black: Control = $"../FadetoBlack"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not Gamestate.is_level_finished:
		
		Gamestate.is_level_finished = true # Being set true here and in Gamestate. May want to remove and test later
		
		# Stop background music with fadeout
		var music_tween = create_tween()
		music_tween.tween_property(
			Music.background_music,
			"volume_db",
			-80,
			1.5
		)
		finish_sound.play()
		Gamestate.cannot_move = true
		timer.start()

		# Fade screen to black
		var fade_node = body.get_node("FadetoBlack")
		if fade_node:
			var fade_tween = create_tween()
			fade_tween.tween_property(
				fade_node,
				"modulate:a", # Modify the alpha channel
				1.0, # Fully opaque
				1.5  
		)

func _on_timer_timeout() -> void:
	Gamestate.level_complete()
