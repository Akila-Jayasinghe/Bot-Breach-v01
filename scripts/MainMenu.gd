extends CanvasLayer

@onready var start_button = $TextureRect/MarginContainer/VBoxContainer/Button
@onready var exit_button = $TextureRect/MarginContainer/VBoxContainer/Button2

func _ready():
	#print("You are in the main menu")
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Make buttons focusable
	start_button.grab_focus()

func _on_start_button_pressed():
	#print("Starting game...")
	# Load your main game scene - change the path to your actual game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_button_pressed():
	#print("Exiting game...")
	get_tree().quit()

# Optional: Add keyboard navigation
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if start_button.has_focus():
			_on_start_button_pressed()
		elif exit_button.has_focus():
			_on_exit_button_pressed()
