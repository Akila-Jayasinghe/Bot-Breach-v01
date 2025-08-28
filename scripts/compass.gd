extends Sprite2D

@export var target_node: Node2D
@export var compass_scale: float = 0.05
@export var texture_rotation_offset: float = 0.0

# --- Distance Color Settings ---
@export var max_distance: float = 1000.0  # Distance where color becomes red
@export var min_distance: float = 100.0   # Distance where color becomes green
@export var distance_gradient: Gradient  # Color gradient for distance visualization

# --- Transparency Settings ---
@export var base_alpha: float = 0.6  # Overall transparency (0.0 = invisible, 1.0 = opaque)
@export var min_alpha: float = 0.3   # Minimum transparency when far away
@export var max_alpha: float = 0.8   # Maximum transparency when close

func _ready():
	z_index = 1000
	show()
	centered = true
	offset = Vector2.ZERO
	scale = Vector2(compass_scale, compass_scale)
	modulate = Color(1, 1, 1, base_alpha)  # Start with base transparency
	
	# Create optimal gradient if none is set in Inspector
	if not distance_gradient:
		#print("Creating default gradient...")
		_create_optimal_gradient()
	#else:
		#print("Using custom gradient from Inspector")
	
	# Debug: Print gradient info
	#if distance_gradient:
		#print("Gradient has ", distance_gradient.get_point_count(), " color points")
	#else:
		#print("❌ ERROR: Gradient is still null!")

func _create_optimal_gradient():
	distance_gradient = Gradient.new()
	# Optimal gradient: Green (close) -> Yellow -> Orange -> Red (far)
	distance_gradient.add_point(0.0, Color(0.2, 1.0, 0.2, 1.0))   # Bright Green - very close
	distance_gradient.add_point(0.3, Color(0.8, 1.0, 0.2, 1.0))   # Green-Yellow - close
	distance_gradient.add_point(0.6, Color(1.0, 0.8, 0.2, 1.0))   # Yellow-Orange - medium
	distance_gradient.add_point(1.0, Color(1.0, 0.3, 0.3, 1.0))   # Red - far
	#print("Optimal gradient created with 4 color points")

func _process(_delta):
	if not target_node:
		# Flash red if no target (with transparency)
		var flash_alpha = 0.7 if fmod(Time.get_ticks_msec(), 1000) < 500 else 0.4
		modulate = Color(1, 0, 0, flash_alpha)
		return
	
	# Calculate direction and rotation
	var direction = (target_node.global_position - global_position).normalized()
	rotation = direction.angle() + texture_rotation_offset
	
	# Calculate distance to target
	var distance = global_position.distance_to(target_node.global_position)
	
	# Update color based on distance
	_update_compass_color(distance)

func _update_compass_color(distance: float):
	if not distance_gradient:
		modulate = Color(1, 0, 1, base_alpha)  # Error color with transparency
		return
	
	# Calculate normalized distance ratio (0.0 to 1.0)
	var distance_ratio = clamp((distance - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	
	# Get color from gradient with safety check
	var base_color = distance_gradient.sample(distance_ratio)
	
	# Ensure valid color values
	base_color.r = clamp(base_color.r, 0.0, 1.0)
	base_color.g = clamp(base_color.g, 0.0, 1.0)
	base_color.b = clamp(base_color.b, 0.0, 1.0)
	
	# Calculate dynamic alpha based on distance (more transparent when farther)
	var alpha = lerp(max_alpha, min_alpha, distance_ratio)
	
	# Apply color with transparency
	modulate = Color(base_color.r, base_color.g, base_color.b, alpha)
	
	# Debug: Print info occasionally
	#if fmod(Time.get_ticks_msec(), 2000) < 50:
		#print("Distance: ", int(distance), " | Alpha: ", alpha)

# Optional: Display distance text (with transparency)
func _draw():
	if not target_node or not distance_gradient:
		return
	
	var distance = global_position.distance_to(target_node.global_position)
	var distance_text = str(int(distance)) + "m"
	
	# Choose text color based on distance
	var distance_ratio = clamp((distance - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	var text_color = distance_gradient.sample(distance_ratio)
	text_color.a = 0.7  # Slightly more opaque text
	
	# Ensure valid text color
	text_color.r = clamp(text_color.r, 0.0, 1.0)
	text_color.g = clamp(text_color.g, 0.0, 1.0)
	text_color.b = clamp(text_color.b, 0.0, 1.0)
	
	# Draw distance text below compass
	var font = ThemeDB.fallback_font
	var font_size = 14
	var text_position = Vector2(-15, 25)
	
	# Draw text with slight shadow for readability (also transparent)
	draw_string(font, text_position + Vector2(1, 1), distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, 0.5))
	draw_string(font, text_position, distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# Simple manual color setter for testing (with transparency)
func set_manual_color(distance: float):
	# Fallback method if gradient still doesn't work
	var distance_ratio = clamp((distance - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	var alpha = lerp(max_alpha, min_alpha, distance_ratio)
	
	if distance < min_distance:
		modulate = Color(0.2, 1.0, 0.2, alpha)  # Green
	elif distance < max_distance * 0.3:
		modulate = Color(0.8, 1.0, 0.2, alpha)  # Green-Yellow
	elif distance < max_distance * 0.6:
		modulate = Color(1.0, 0.8, 0.2, alpha)  # Yellow-Orange
	else:
		modulate = Color(1.0, 0.3, 0.3, alpha)  # Red
