extends Node2D

@export var rotation_speed : float = 45.0
@export var rotation_range : float = 180.0
@export var detection_color : Color = Color(1, 0, 0)
@export var warning_color : Color = Color(1, 1, 0)
@export var normal_color : Color = Color(1, 1, 1)
@export var cooldown_time : float = 0.5
@export var tracking_speed : float = 2.0

@export var color_timer_path: NodePath

var direction = 1
var start_rotation = 0.0
var player_detected = false
var tracking_player = false
var cooldown_timer = 0.0

var player: CharacterBody2D

@onready var light = $PointLight2D
@onready var area = $Area2D
var color_timer: Timer = null

func _ready():
	start_rotation = rotation_degrees
	light.color = normal_color
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	# Assign timer node safely
	if color_timer_path != NodePath():
		var timer_node = get_node_or_null(color_timer_path)
		if timer_node and timer_node is Timer:
			color_timer = timer_node
			color_timer.timeout.connect(_on_color_timer_timeout)
		else:
			push_error("Assigned node is not a valid Timer: %s" % str(color_timer_path))
	else:
		push_warning("No color_timer_path set.")

func _process(delta):
	if tracking_player and is_instance_valid(player):
		var target_angle = (player.global_position - global_position).angle()
		var target_degrees = rad_to_deg(target_angle)
		var clamped_angle = clamp(target_degrees, start_rotation - rotation_range / 2, start_rotation + rotation_range / 2)
		rotation_degrees = lerp_angle(rotation_degrees, clamped_angle, tracking_speed * delta)

	elif not player_detected:
		rotation_degrees += rotation_speed * direction * delta
		if rotation_degrees > start_rotation + rotation_range / 2:
			rotation_degrees = start_rotation + rotation_range / 2
			direction = -1
		elif rotation_degrees < start_rotation - rotation_range / 2:
			rotation_degrees = start_rotation - rotation_range / 2
			direction = 1
	else:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			player_detected = false
			tracking_player = false
			light.color = normal_color
			if color_timer:
				color_timer.stop()

func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_detected = true
		tracking_player = true
		light.color = warning_color
		cooldown_timer = cooldown_time
		if color_timer:
			color_timer.start()

func _on_body_exited(body):
	if body.name == "Player":
		tracking_player = false
		cooldown_timer = cooldown_time
		if color_timer:
			color_timer.stop()
		light.color = normal_color

func _on_color_timer_timeout():
	if player_detected:
		light.color = detection_color
