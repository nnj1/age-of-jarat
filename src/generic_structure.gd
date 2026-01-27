extends StaticBody2D

class_name Structure

@onready var main_game_node = get_tree().get_root().get_node('Game')
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var tile_layer: TileMapLayer

var lore_data
var faction: int
var allies: Array[int]

@onready var selection_visual = $SelectionCircle # A Sprite2D child used for feedback

# sets the authority and faction of the unit
func prepare(spawning_player_id: int = 1, given_faction:int = randi_range(0, 1), given_lore_data = GlobalVars.lore.structures.pick_random()):
	set_multiplayer_authority(spawning_player_id)
	faction = given_faction
	allies.append(faction)
	lore_data = given_lore_data
	
func _ready():
	if not is_multiplayer_authority(): return
	
	# add in the correct sprites if it exists
	var potential_sprite = load('res://scenes/entities/structures/structure_sprites/' + lore_data.name.to_lower() + '.tscn')
	if potential_sprite:
		$Sprites.queue_free()
		self.add_child(potential_sprite.instantiate())
	
	# create a collision layer based on tier 1 sprite
	tile_layer = $'Sprites/1'
	update_collision_to_layer()
	
	# only show the first tier of the structure initially
	for child in $Sprites.get_children():
		child.hide()
	$"Sprites/1".show()
	
	# connect important signals
	if get_node_or_null('HealthComponent'):
		$HealthComponent.died.connect(on_death)
		$HealthComponent.just_took_damage.connect(play_damage_modulate_animation)
		if get_node_or_null('SoundComponent'):
			$HealthComponent.died.connect($SoundComponent.play_death_sound)
			$HealthComponent.just_took_damage.connect($SoundComponent.play_hurt_sound)
	
	if selection_visual:
		selection_visual.visible = false

func on_death():
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func play_damage_modulate_animation():
	for sprite in $Sprites.get_children(): 
		var tween = get_tree().create_tween()
		# Transition to Red
		tween.tween_property(sprite, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_SINE)
		# Transition back to White (Normal)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1).set_trans(Tween.TRANS_SINE)

func toggle_blue_tint(given_status: bool):
	if given_status:
		self.modulate = Color(0, 0, 1, 0.9)
	else:
		self.modulate = Color(1, 1, 1, 1)
		
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

@warning_ignore("unused_parameter")
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("This structure was clicked!")
			main_game_node.update_structure_menu(self)
			

func _on_mouse_entered() -> void:
	CursorManager.set_cursor(CursorManager.Type.HOVER)

func _on_mouse_exited() -> void:
	CursorManager.reset_cursor()

func update_collision_to_layer() -> void:
	var used_cells = tile_layer.get_used_cells()
	
	if used_cells.is_empty():
		collision_shape.disabled = true
		return
	
	collision_shape.disabled = false
	
	# 1. Find the bounding box of the used cells (in grid coordinates)
	var rect = tile_layer.get_used_rect()
	
	# 2. Convert grid coordinates to local pixel coordinates
	# get_used_rect() returns position (top-left cell) and size (how many cells)
	var tile_size = tile_layer.tile_set.tile_size
	
	# Calculate the pixel size and center
	var pixel_size = Vector2(rect.size) * Vector2(tile_size)
	var pixel_center = (Vector2(rect.position) * Vector2(tile_size)) + (pixel_size / 2.0)
	
	# 3. Apply to the CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = pixel_size
	
	collision_shape.shape = shape
	collision_shape.position = pixel_center
