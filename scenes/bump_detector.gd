extends Area2D

func _ready():
	# Connect the signal for when a body enters this area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the entering body is the player
	if body.is_in_group("player"):
		print("Player entered menu return zone!")
		# Return to main menu immediately
		
		get_tree().change_scene_to_file("res://scenes/busted.tscn")
