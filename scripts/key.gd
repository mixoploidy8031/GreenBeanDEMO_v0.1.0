extends Area2D

@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GlobalStats.total_keys += 1
		animation_player.play("pickup")
		
