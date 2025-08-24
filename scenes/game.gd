extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set to fullscreen mode (Godot 4 syntax)
	get_window().mode = Window.MODE_FULLSCREEN
	
	# Optional: Also set the window size to your desired resolution
	# get_window().size = Vector2i(1920, 1080)  # Replace with your monitor's resolution

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
