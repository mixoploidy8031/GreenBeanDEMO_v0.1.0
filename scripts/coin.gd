extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		game_manager.add_point()
		GlobalStats.total_coins += 1 # Increase coins globally
		animation_player.play("pickup")
