extends Area2D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var platform_3: AnimatableBody2D = $".."

var animation_triggered: bool = false 

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not animation_triggered:
		animation_triggered = true
		animation_player.play("platmoveshake")
		collision_shape.queue_free()
		await  animation_player.animation_finished
		platform_3.queue_free()
