extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager: Node = %GameManager
@onready var player: CharacterBody2D = $"../../../Player"

var timer_duration: float = 1.0 # Duration for the timer (IF NOT EQUAL TO GAMESTATE FADE DURATION ONE WILL COMPLETE BEFORE THE OTHER)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Start fade effect & slow time
		var fade_node = body.get_node("FadetoBlack")
		if fade_node and fade_node is ColorRect:
			var tween = create_tween()
			tween.tween_property(
				fade_node,
				"modulate:a", # Modify the alpha channel
				1.0, # Fully opaque
				1.0  #Fade duration (1 second)
		)

		# Call the player's collision logic if implemented
		if body.has_method("_on_body_entered"):
			body._on_body_entered(self)
			
		Engine.time_scale = 0.5
	
		 # Update global state
		Gamestate.cannot_move = true
		Gamestate.alive = false
	
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").queue_free()  # Optionally remove collision shape
		
		timer.wait_time = timer_duration
		timer.start() # Start the timer for the scene reload
	
func _on_timer_timeout() -> void:
	# Reset the time scale and reload the scene
	Engine.time_scale = 1
	get_tree().reload_current_scene()
	Gamestate.cannot_move = false
	Gamestate.alive = true
