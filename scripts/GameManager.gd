extends Node

signal game_over(reason)

var is_game_over = false

func end_game(reason: String = "You are Busted!"):
	if is_game_over:
		return
	
	is_game_over = true
	emit_signal("game_over", reason)
	
	# Freeze the game
	Engine.time_scale = 0.0
	print("Game Over: ", reason)

func reset_game():
	is_game_over = false
	Engine.time_scale = 1.0
