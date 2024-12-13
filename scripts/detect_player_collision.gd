extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Gamestate.can_pause = false
		print ("Player has entered unpausable location! Setting can_pause to false")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		Gamestate.can_pause = true
		print ("Player has left unpausable location! Setting can_pause to true")
