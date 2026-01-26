extends CharacterBody2D

class_name Unit

@onready var main_game_node = get_tree().get_root().get_node('Game')

# SHOULD ONLY CONTAIN VILLAGER SPRITES
var sprite_atlas_coords_corners = [
	Vector2i(104,0),
	Vector2i(200,32)
]

@export var speed: float = 25.0
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var looking_right = false

var knockback_velocity: Vector2 = Vector2.ZERO

@export var autonomous_mode: bool = true : set = set_autonomous_mode

func set_autonomous_mode(value: bool):
	autonomous_mode = value
	if has_node("WanderComponent"):
		$WanderComponent.set_enabled(value)
		
var random_atlas_coords: Vector2i

var faction: int
var allies: Array[int]

@onready var selection_visual = $SelectionCircle # A Sprite2D child used for feedback

# sets the authority and faction of the unit
func prepare(spawning_player_id: int = 1, given_faction:int = randi_range(0, 1)):
	set_multiplayer_authority(spawning_player_id)
	faction = given_faction
	allies.append(faction)
	
func _ready():
	if not is_multiplayer_authority(): return
	
	# connect important signals
	if get_node_or_null('HealthComponent'):
		$HealthComponent.died.connect(on_death)
		$HealthComponent.just_took_damage.connect(play_damage_modulate_animation)
		if get_node_or_null('SoundComponent'):
			$HealthComponent.died.connect($SoundComponent.play_death_sound)
			$HealthComponent.just_took_damage.connect($SoundComponent.play_hurt_sound)

		
	target_position = global_position
	if selection_visual:
		selection_visual.visible = false
	
	# pick a random player sprite
	random_atlas_coords = GlobalVars.get_vectors_in_range(sprite_atlas_coords_corners[0], sprite_atlas_coords_corners[1]).pick_random()
	
	# make sure it's nonblack otherwise pick again
	while not is_atlas_tile_non_black(random_atlas_coords):
		random_atlas_coords = GlobalVars.get_vectors_in_range(sprite_atlas_coords_corners[0], sprite_atlas_coords_corners[1]).pick_random()
	# TODO: make this an rpc call
	set_unit_texture.rpc(random_atlas_coords)
	
	# create random shader offsets
	$Sprite.material.set_shader_parameter('random_phase', randf_range(0.0, 100.0))
	
	# FOW check
	_setup_fog_timer()

func _setup_fog_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.8 # Staggered check to save CPU
	timer.timeout.connect(_check_visibility)
	timer.start()

func _check_visibility():
	var fog_system = get_tree().get_first_node_in_group("FogSystem")
	if not fog_system: return
	
	var is_seen = fog_system.is_pos_revealed(global_position)
	
	# Pass the status to the WanderComponent
	if has_node("WanderComponent"):
		$WanderComponent.is_in_fog = !is_seen
		
@rpc("any_peer","call_local","reliable")
func set_unit_texture(given_random_atlas_coords: Vector2i):
	$Sprite.set_cell(Vector2i(0,0), 0, given_random_atlas_coords)

func set_selected(value: bool):
	# Disable autonomy when selected so the player has full control
	set_autonomous_mode(!value)
	
	is_moving = is_moving # Keeps current state
	if get_node_or_null('UnitController'):
		$UnitController.is_selected = value
	if selection_visual:
		selection_visual.visible = value
	# 3. Update the health bar visibility via the component
	$HealthComponent.set_bar_visibility(value)
	
	# set up the outline for the sprite
	if get_node_or_null('UnitController'):
		$Sprite.material.set_shader_parameter('use_active_state', value)

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

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	

	if not is_moving:
		# only susceptible to knockback, if not moving
		# Gradually friction away the knockback so they don't slide forever
		knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.1)
		velocity = knockback_velocity
		move_and_slide()
	else:
		var distance_to_target = global_position.distance_to(target_position)
		
		# 1. Check if we are close enough to stop BEFORE moving
		# Increase the tolerance (e.g., 2.0 or 4.0) for high speeds
		if distance_to_target < 2.0:
			global_position = target_position # Snap to exact target
			velocity = Vector2.ZERO
			is_moving = false
			stop_jumping()
			return
			
		# Gradually friction away the knockback so they don't slide forever
		knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.1)

		# 2. Calculate direction and velocity
		var direction = global_position.direction_to(target_position)
		velocity = direction * speed + knockback_velocity
		
		
		# 3. Move and Slide
		move_and_slide()

func on_death():
	queue_free()

func play_damage_modulate_animation():
	var tween = get_tree().create_tween()
	# Transition to Red
	tween.tween_property($Sprite, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_SINE)
	# Transition back to White (Normal)
	tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1).set_trans(Tween.TRANS_SINE)

func is_atlas_tile_non_black(atlas_coords: Vector2i, tileset_path: String = 'res://resources/urizen.tres', source_id: int = 0) -> bool:
	# 1. Load the TileSet resource
	var tile_set = load(tileset_path) as TileSet
	if not tile_set:
		push_error("Failed to load TileSet at: " + tileset_path)
		return false

	# 2. Get the specific Atlas Source
	var source = tile_set.get_source(source_id) as TileSetAtlasSource
	if not source:
		push_error("Source ID %d not found in TileSet" % source_id)
		return false

	# 3. Get the Image data from the texture
	var texture = source.texture
	if not texture: return false
	var image = texture.get_image()
	
	# 4. Use Godot's built-in helper to find exactly where the tile sits in the image
	var region = source.get_tile_texture_region(atlas_coords)
	
	# 5. Scan the pixels in that region
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			var pixel_color = image.get_pixel(x, y)
			
			# We check 'v' (Value/Brightness) and 'a' (Alpha)
			# This ignores pixels that are black OR fully transparent
			if pixel_color.v > 0.01 and pixel_color.a > 0.05:
				return true
				
	return false
