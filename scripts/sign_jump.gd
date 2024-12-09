extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var intro_instructions: Node2D = $IntroInstructions
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enter_timer: Timer = $EnterTimer
@onready var exit_timer: Timer = $ExitTimer
@onready var player: CharacterBody2D = $"../../Player"

var is_player_inside: bool = false
var is_animation_playing: bool = false
var fade_in_completed: bool = false

# Ensure the label is hidden initially
func _on_ready() -> void:
	intro_instructions.visible = false
	enter_timer.connect("timeout", Callable(self, "_on_enter_timer_timeout"))
	exit_timer.connect("timeout", Callable(self, "_on_exit_timer_timeout"))
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
# Triggered when the player enters the collision area
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_animation_playing and not fade_in_completed:
		is_player_inside = true
		exit_timer.stop() # Cancel exit timer if running
		enter_timer.start() # Delay to let the player settle before showing the label

# Triggered when the player leaves the collision area
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and intro_instructions.visible:
		is_player_inside = false
		exit_timer.start()

# Display the message with fade-in animation
func _show_message() -> void:
	if animation_player.is_playing():
		animation_player.stop() # Stop any ongoing animation
	is_animation_playing = true
	intro_instructions.visible = true
	animation_player.play("fadeintext")

# Called when the enter timer times out
func _on_enter_timer_timeout() -> void:
	enter_timer.stop()
	if is_player_inside and not fade_in_completed:
		_show_message()

# Hide the message with fade-out animation when the timer times out
func _on_exit_timer_timeout() -> void:
	if not is_player_inside and intro_instructions.visible and not is_animation_playing and fade_in_completed: 
		is_animation_playing = true
		animation_player.play("fadeouttext")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	is_animation_playing = false
	if anim_name == "fadeintext":
		fade_in_completed = true
	elif anim_name == "fadeouttext" and not is_player_inside:
		intro_instructions.visible = false # Hide the label only after fade-out complete
		queue_free()
