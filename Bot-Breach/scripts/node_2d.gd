extends Node2D

@export var rotation_speed : float = 45.0 # degrees per second
@export var rotation_range : float = 180.0 # total rotation range

var direction = 1
var start_rotation = 0.0

func _ready():
	start_rotation = rotation_degrees

func _process(delta):
	# rotate back and forth
	rotation_degrees += rotation_speed * direction * delta

	if rotation_degrees > start_rotation + rotation_range / 2:
		rotation_degrees = start_rotation + rotation_range / 2
		direction = -1
	elif rotation_degrees < start_rotation - rotation_range / 2:
		rotation_degrees = start_rotation - rotation_range / 2
		direction = 1
