extends CharacterBody2D

# --- Patrol Settings ---
@export var patrol_speed: float = 45.0
@export var waypoints_path: NodePath
var waypoints: Array[Vector2] = []
var current_waypoint_index: int = 0

# --- Chase & Vision Settings ---
@export var chase_speed: float = 90.0
@export var vision_range: float = 135.0
@export var vision_angle: float = 90.0 # Field of view in degrees
@export var chase_time_after_lost: float = 3.0 # 3 second chase cooldown
var target_player: Node2D = null
var last_seen_position: Vector2

# --- State Machine ---
enum State { PATROL, CHASE, SUSPICIOUS, STUNNED }
var current_state: State = State.PATROL
var player_last_position: Vector2 # Track player movement during stun

# --- Node References ---
@onready var vision_area: Area2D = $Vision
@onready var vision_cone: Node2D = $VisionConeVisual
@onready var chase_timer: Timer = $ChaseTimer

# --- Timer Setup ---
func _ready():
	# Load waypoints
	var waypoint_container = get_node(waypoints_path)
	for child in waypoint_container.get_children():
		waypoints.append(child.global_position)
	if waypoints.size() > 0:
		global_position = waypoints[0]
	
	# Configure Timer
	chase_timer.wait_time = chase_time_after_lost
	chase_timer.one_shot = true
	chase_timer.timeout.connect(_on_chase_timer_timeout)
	
	# Connect vision signals
	vision_area.body_entered.connect(_on_vision_body_entered)
	vision_area.body_exited.connect(_on_vision_body_exited)
	
	# Connect bump detection signal
	$BumpDetector.body_entered.connect(_on_bump_detector_body_entered)

func _physics_process(delta):
	# Check if player moves while we're stunned (to resume chase)
	if current_state == State.STUNNED && target_player:
		# Check if player has moved from their last recorded position
		if target_player.global_position.distance_to(player_last_position) > 2.0:
			print("Player moved! Resuming chase from stun.")
			current_state = State.CHASE
		
		# Keep facing the player while stunned
		vision_cone.rotation = (target_player.global_position - global_position).angle()
	
	# Choose behavior based on state
	match current_state:
		State.PATROL:
			patrol(delta)
		State.CHASE:
			chase(delta)
		State.SUSPICIOUS:
			suspicious(delta)
		State.STUNNED:
			# Do nothing - just stay stunned until player moves
			pass
	
	move_and_slide()
	
	# Update the vision cone drawing every frame
	queue_redraw()

func _draw():
	# Choose a color based on the drone's state
	var color = Color(1, 1, 1, 0.2)  # WHITE, transparent (for PATROL state)
	match current_state:
		State.CHASE:
			color = Color(1, 0, 0, 0.3)  # RED when chasing
		State.SUSPICIOUS:
			color = Color(1, 0.8, 0, 0.3) # Yellow-orange when suspicious
		State.STUNNED:
			color = Color(1, 0, 0, 0.4)  # RED when stunned (same as chase but slightly more opaque)
	
	# Draw a FULL CIRCLE for the vision range
	draw_circle(Vector2.ZERO, vision_range, color)

func patrol(_delta):
	if waypoints.is_empty():
		return
	
	var target_waypoint: Vector2 = waypoints[current_waypoint_index]
	var direction: Vector2 = (target_waypoint - global_position).normalized()
	velocity = direction * patrol_speed
	
	# Rotate the vision cone to face the movement direction
	if velocity.length() > 0:
		vision_cone.rotation = velocity.angle()
	
	if global_position.distance_to(target_waypoint) < 5.0:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

func chase(_delta):
	if target_player:
		var direction: Vector2 = (target_player.global_position - global_position).normalized()
		velocity = direction * chase_speed
		last_seen_position = target_player.global_position
		# Keep the vision cone facing the player we're chasing
		vision_cone.rotation = direction.angle()

func suspicious(_delta):
	# Move towards the last place we saw the player
	var direction: Vector2 = (last_seen_position - global_position).normalized()
	velocity = direction * patrol_speed # Use patrol speed for searching
	vision_cone.rotation = direction.angle()
	
	# Check if we've reached the last seen position
	if global_position.distance_to(last_seen_position) < 5.0:
		velocity = Vector2.ZERO # Stop and look around

func _on_bump_detector_body_entered(body):
	if (current_state == State.CHASE || current_state == State.SUSPICIOUS) && body.is_in_group("player"):
		print("Drone bumped into player! Permanently stunned until player moves.")
		current_state = State.STUNNED
		velocity = Vector2.ZERO
		# Record the player's position at the moment of stun
		player_last_position = target_player.global_position

# --- VISION SIGNAL HANDLERS ---
func _on_vision_body_entered(body):
	# DEBUG: Print ANY body that enters the vision area
	print("Vision detected something: ", body.name)
	
	if body.is_in_group("player"):
		print("DRONE ALERT: Player entered vision!")
		target_player = body
		# Allow vision detection to work even when stunned
		if current_state == State.STUNNED:
			print("Drone recovered from stun! Resuming chase.")
		current_state = State.CHASE
		chase_timer.stop()
	else:
		print("It was not the player. It was in groups: ", body.get_groups())

func _on_vision_body_exited(body):
	if body == target_player:
		# Only start timer if we're not stunned
		if current_state != State.STUNNED:
			chase_timer.start()
			current_state = State.SUSPICIOUS # Switch to suspicious state
		else:
			print("Player escaped while drone was stunned.")

func _on_chase_timer_timeout():
	# This runs after 3 seconds if the player hasn't been re-spotted
	print("Drone gave up the chase.")
	target_player = null
	current_state = State.PATROL # Return to patrol
