extends CharacterBody2D

# How fast the drone moves normally
@export var patrol_speed: float = 60.0
# Drag the Waypoints node here in the Inspector!
@export var waypoints_path: NodePath

# List to store the positions of our waypoints
var waypoints: Array[Vector2] = []
# Keeps track of which waypoint we're going towards
var current_waypoint_index: int = 0

func _ready():
	# This function runs when the drone is added to the game
	# 1. Get the waypoint container node we linked in the Inspector
	var waypoint_container = get_node(waypoints_path)
	
	# 2. Loop through all children of the container and save their positions
	for child in waypoint_container.get_children():
		waypoints.append(child.global_position)
	
	# Start the drone at the first waypoint (optional)
	if waypoints.size() > 0:
		global_position = waypoints[0]

func _physics_process(delta):
	# This function runs every physics frame (60 times per second)
	
	# If there are no waypoints, just stop and do nothing.
	if waypoints.is_empty():
		return
	
	# 1. Figure out which waypoint we're targeting
	var target_waypoint: Vector2 = waypoints[current_waypoint_index]
	
	# 2. Calculate the direction to move in
	#    (Target Position - Our Current Position) -> then normalize it to a length of 1
	var direction: Vector2 = (target_waypoint - global_position).normalized()
	
	# 3. Set our velocity (direction * speed)
	velocity = direction * patrol_speed
	
	# 4. Move the drone! This function handles the collision and movement.
	move_and_slide()
	
	# 5. Check if we are very close to the target waypoint
	if global_position.distance_to(target_waypoint) < 5.0:
		# If yes, move to the next waypoint in the list.
		current_waypoint_index += 1
		# If we were at the last waypoint, loop back to the first one (index 0).
		if current_waypoint_index >= waypoints.size():
			current_waypoint_index = 0
