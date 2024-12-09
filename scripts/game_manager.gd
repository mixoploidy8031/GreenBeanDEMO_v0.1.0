extends Node

@onready var player: CharacterBody2D = $"../Player"
@onready var score_label: Label = $ScoreLabel
@onready var coins_done_sound: AudioStreamPlayer2D = $"../Player/Coinsdonesound"

var score = 0
var total_coins: int = 30

func _on_ready() -> void:
	if Gamestate.game_started:
		update_score_label()

func add_point():
	score += 1
	update_score_label()

	# Play 'coins_done' sound when total coins collected
	if score == total_coins:
		coins_done_sound.play()

func update_score_label():
	score_label.text =  str(score) + " of " + str(total_coins) + " coins"

func stop_game() -> void:
	# Call this to pause or stop the game
	Gamestate.game_started = false
	set_process(false)
