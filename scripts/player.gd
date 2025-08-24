extends CharacterBody2D

@export var speed: float = 150
@export var dash_speed: float = 500
@export var dash_duration: float = 0.1
@export var dash_cooldown: float =  3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dashing = false
var dash_timer = 0.0
var cooldown_timer = 0.0
var last_direction = Vector2.RIGHT  # default facing right

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	# Update last facing direction when moving
	if input_vector != Vector2.ZERO:
		last_direction = input_vector

	# Handle dash input
	if Input.is_action_just_pressed("ui_accept") and !is_dashing and cooldown_timer <= 0.0:
		is_dashing = true
		dash_timer = dash_duration
		cooldown_timer = dash_cooldown

	# Dash logic
	if is_dashing:
		velocity = last_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity = input_vector * speed

	# Move
	move_and_slide()

	# Flip sprite horizontally
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

	# Switch animations (only when not dashing)
	if !is_dashing:
		if input_vector == Vector2.ZERO:
			if sprite.animation != "idle":
				sprite.play("idle")
		else:
			if sprite.animation != "run":
				sprite.play("run")

	# Handle cooldown timer
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
