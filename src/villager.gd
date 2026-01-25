extends CharacterBody2D

class_name Unit

var sprite_atlas_coords_corners = [
	Vector2i(104,2),
	Vector2i(144,10)
]

@export var speed: float = 25.0
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var looking_right = false

@onready var selection_visual = $SelectionCircle # A Sprite2D child used for feedback

func prepare(spawning_player_id: int = 1):
	set_multiplayer_authority(spawning_player_id)

func _ready():
	if not is_multiplayer_authority(): return
	
	# connect important signals
	$HealthComponent.died.connect($SoundComponent.play_death_sound)
	$HealthComponent.died.connect(on_death)
	
	$HealthComponent.just_took_damage.connect($SoundComponent.play_hurt_sound)
	
	
	target_position = global_position
	if selection_visual:
		selection_visual.visible = false
		
	# pick a random player sprite
	var random_atlas_coords = get_vectors_in_range(sprite_atlas_coords_corners[0], sprite_atlas_coords_corners[1]).pick_random()
	
	# TODO: make this an rpc call
	set_unit_texture.rpc(random_atlas_coords)
	
	# create random shader offsets
	$Sprite.material.set_shader_parameter('random_phase', randf_range(0.0, 100.0))

@rpc("any_peer","call_local","reliable")
func set_unit_texture(given_random_atlas_coords: Vector2i):
	$Sprite.set_cell(Vector2i(0,0), 0, given_random_atlas_coords)

func set_selected(value: bool):
	is_moving = is_moving # Keeps current state
	$UnitController.is_selected = value
	if selection_visual:
		selection_visual.visible = value
	# 3. Update the health bar visibility via the component
	$HealthComponent.set_bar_visibility(value)

func _on_mouse_entered():
	# Useful if you want the cursor to change when hovering over a clickable unit
	CursorManager.set_cursor(CursorManager.Type.HOVER)

func _on_mouse_exited():
	CursorManager.reset_cursor()

@rpc("any_peer","call_local","reliable")
func start_jumping():
	$Sprite.material.set_shader_parameter('height', 3)

@rpc("any_peer","call_local","reliable")
func stop_jumping():
	$Sprite.material.set_shader_parameter('height', 0)
	
func set_move_target(new_target: Vector2):
	target_position = new_target
	is_moving = true
	start_jumping()
	if new_target.x > self.global_position.x:
		# flip self
		if not looking_right:
			$Sprite.scale.x = -1
			$Sprite.position.x += 12
			looking_right = true
	else:
		if looking_right:
			$Sprite.scale.x = 1
			$Sprite.position.x -= 12
			looking_right = false

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	
	if get_node_or_null('UnitController'):
		if $UnitController.is_selected:
			$Sprite.material.set_shader_parameter('use_active_color', true)
		else:
			$Sprite.material.set_shader_parameter('use_active_color', false)

	
	if not is_moving:
		return
	
	var distance_to_target = global_position.distance_to(target_position)
	
	# 1. Check if we are close enough to stop BEFORE moving
	# Increase the tolerance (e.g., 2.0 or 4.0) for high speeds
	if distance_to_target < 2.0:
		global_position = target_position # Snap to exact target
		velocity = Vector2.ZERO
		is_moving = false
		stop_jumping()
		return

	# 2. Calculate direction and velocity
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	
	# 3. Move and Slide
	move_and_slide()

func get_vectors_in_range(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	# Create a Rect2i from two points. 
	# abs() ensures it works even if p2 is "behind" p1.
	var rect = Rect2i(p1, Vector2i.ZERO).expand(p2)
	
	# Loop through the X and Y range
	# We use rect.end + 1 if you want the border included
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			points.append(Vector2i(x, y))
			
	return points

func on_death():
	queue_free()
