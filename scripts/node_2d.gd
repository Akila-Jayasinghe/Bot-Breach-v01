extends Node2D

@export var rotation_speed : float = 45.0 # degrees per second
@export var rotation_range : float = 180.0 # total rotation range
@export var detection_color : Color = Color(1, 0, 0) # red
@export var normal_color : Color = Color(1, 1, 1) # white
@export var cooldown_time : float = 3.0
@export var tracking_speed : float = 2.0  # speed to rotate toward player

var direction = 1
var start_rotation = 0.0
var player_detected = false
var cooldown_timer = 0.0
var tracking_player = false

var player : CharacterBody2D
@onready var light = $PointLight2D
@onready var area = $Area2D

func _ready():
	start_rotation = rotation_degrees
	light.color = normal_color
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	if tracking_player and is_instance_valid(player):
		# Calculate angle to player
		var target_angle = (player.global_position - global_position).angle()
		var target_degrees = rad_to_deg(target_angle)
		
		# Convert to local space relative to start_rotation
		var clamped_angle = clamp(target_degrees, start_rotation - rotation_range / 2, start_rotation + rotation_range / 2)
		rotation_degrees = lerp_angle(rotation_degrees, clamped_angle, tracking_speed * delta)

	elif not player_detected:
		# Default patrol rotation
		rotation_degrees += rotation_speed * direction * delta
		if rotation_degrees > start_rotation + rotation_range / 2:
			rotation_degrees = start_rotation + rotation_range / 2
			direction = -1
		elif rotation_degrees < start_rotation - rotation_range / 2:
			rotation_degrees = start_rotation - rotation_range / 2
			direction = 1
	else:
		# Cooldown time (still, but not tracking)
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			player_detected = false
			light.color = normal_color
			tracking_player = false

func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_detected = true
		tracking_player = true
		light.color = detection_color
		cooldown_timer = cooldown_time

func _on_body_exited(body):
	if body.name == "Player":
		tracking_player = false
		# Keep red light on during cooldown
		cooldown_timer = cooldown_time
