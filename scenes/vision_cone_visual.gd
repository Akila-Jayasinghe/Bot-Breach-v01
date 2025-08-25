extends Node2D

# This script simply forces the parent drone to draw its vision cone
# at this node's position.

func _ready():
	# Tell Godot to call this node's _draw() function every frame
	queue_redraw()

func _draw():
	# Get the parent drone and let it handle the drawing logic
	get_parent().call("_draw")
