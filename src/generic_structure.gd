extends StaticBody2D

class_name Structure

@onready var main_game_node = get_tree().get_root().get_node('Game')

var lore_data
var faction: int
var allies: Array[int]

@onready var current_tier: int = 1

# Variables governing building
var building_status:bool = true # keeps track of if the unit is still being build
var cooldown = 10.0 # base cooldown time
var time_passed = 0.0
var speed_multiplier = 1.0 # Change this to 2.0, 5.0, etc. Will be modified by builders
var assigned_builders = []  # contains the Units that can build the structure

@onready var selection_visual = $SelectionCircle # A Sprite2D child used for feedback

# sets the authority and faction of the unit
func prepare(spawning_player_id: int = 1, given_faction:int = randi_range(0, 1), given_lore_data = GlobalVars.lore.structures.pick_random()):
	set_multiplayer_authority(spawning_player_id)
	faction = given_faction
	allies.append(faction)
	lore_data = given_lore_data
	cooldown = lore_data.spawn_speed
	
func start_building():
	building_status = true
	self.modulate = Color(1, 1, 1, 0.5)
	$BuildComponent.modulate = Color(1, 1, 1, 1)
	$SoundComponent/buildingSound.play()
	
func stop_building():
	self.modulate = Color(1, 1, 1, 1)
	building_status = false
	# free all the builders
	for builder in assigned_builders:
		builder.assigned_structure = null
		builder.build_mode = false	
		# update UI without swapping to it
		main_game_node.update_unit_menu(builder, false)
		
	$SoundComponent/buildCompleteSound.play()
	
func _ready():
	if not is_multiplayer_authority(): return
	
	# add in the correct sprites if it exists
	var potential_sprite = load('res://scenes/entities/structures/structure_sprites/' + lore_data.name.to_lower() + '.tscn')
	if potential_sprite:
		$Sprites.queue_free()
		var potential_sprite_instance = potential_sprite.instantiate()
		# only show the first tier of the structure initially
		for child in potential_sprite_instance.get_children():
			child.hide()
		potential_sprite_instance.get_node('1').show()
		
		self.add_child(potential_sprite_instance) # AUTOMATICALLY MODIFIES THE COLISION SHAPE 
	
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
	
func get_timer_percentage() -> float:
	# Returns a value between 0.0 and 1.0
	return time_passed / cooldown

func _process(delta):
	# adjust the speed multiplier based on units assigned to build the structure
	speed_multiplier = 1.0
	for builder in assigned_builders:
		if builder:
			speed_multiplier += builder.lore_data.stats.building_speed
		
	if time_passed < cooldown:
		# We multiply delta to "trick" the math into thinking more time passed
		time_passed += delta * speed_multiplier
		if time_passed >= cooldown:
			stop_building()
	
	# handle building progress bar
	if building_status:
		$BuildComponent.show()
		var progress = get_timer_percentage()
		$BuildComponent.set_progress(progress * 100)
	else:
		$BuildComponent.hide()

func play_damage_modulate_animation():
	for sprite in get_child_in_group('structure_sprites').get_children():
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
			print("This structure was clicked! This will show menu details")
			main_game_node.update_structure_menu(self, true)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if building_status:
				print("This structure was right clicked. Assigning units to build!")
				self.assign_units(main_game_node.get_node('SelectionManager').selected_units)
			else:
				# Do some other shit that requires assignment, like repairing the structure
				print("This structure was right clicked. Assigning units to do some other shit!")
				
## This function assigns units to help build the structure
func assign_units(given_unit_list: Array):
	for unit in given_unit_list:
		# Check if the unit can actually build
		if 'building_speed' in unit.lore_data.stats:
			# Turn off autonomous mode and turn on build mode and assign the structure to the unit
			unit.autonomous_mode = false
			unit.build_mode = true
			unit.assigned_structure = self
			# update the game menu to reflect the new assignment, but don't swap to tab
			main_game_node.update_unit_menu(unit, false)
			
			# add the unit if it wasn't already in the list
			if not unit in assigned_builders:
				assigned_builders.append(unit)

func _on_mouse_entered() -> void:
	CursorManager.set_cursor(CursorManager.Type.HOVER)

func _on_mouse_exited() -> void:
	CursorManager.reset_cursor()

func get_child_in_group(group_name: String) -> Node:
	for child in get_children():
		if child.is_in_group(group_name):
			return child
	return null # Returns null if nobody matches
