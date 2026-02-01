extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')
@onready var selection_manager = get_tree().get_first_node_in_group('manager')

# Signals for both interactions
signal tile_pressed(layer_node, map_coords, atlas_coords)
signal tile_hovered(layer_node, map_coords, atlas_coords)

# Tracking variables to prevent signal spam
var last_hovered_tile: Vector2i = Vector2i(-1, -1)
var last_hovered_layer: TileMapLayer = null

var over_left_clickable_tile: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# 1. HANDLE CLICKS
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile_data = _get_top_tile_at_mouse()
		if tile_data:
			tile_pressed.emit(tile_data.layer, tile_data.map_coords, tile_data.atlas_coords)
			print("Clicked: ", tile_data.atlas_coords, " on ", tile_data.layer.name)
			_on_tile_clicked(tile_data.layer, tile_data.map_coords, tile_data.atlas_coords)
			
	# 2. HANDLE HOVER (Mouse Motion)
	if event is InputEventMouseMotion:
		var tile_data = _get_top_tile_at_mouse()
		
		if tile_data:
			# Only trigger if we moved to a DIFFERENT tile or layer
			if tile_data.atlas_coords != last_hovered_tile or tile_data.layer != last_hovered_layer:
				last_hovered_tile = tile_data.atlas_coords
				last_hovered_layer = tile_data.layer
				
				_on_tile_hover_entered(tile_data.layer, tile_data.map_coords, tile_data.atlas_coords)
		else:
			# Mouse is over empty space
			if last_hovered_tile != Vector2i(-1, -1):
				_on_tile_hover_exited()
				last_hovered_tile = Vector2i(-1, -1)
				last_hovered_layer = null

## Helper function to find which tile is under the mouse (top-down)
func _get_top_tile_at_mouse() -> Dictionary:
	var layers = get_parent().get_children().filter(func(node): return node is TileMapLayer)
	layers.reverse() # Check top visual layers first
	
	for layer in layers:
		var local_pos = layer.to_local(get_global_mouse_position())
		var map_coords = layer.local_to_map(local_pos)
		var atlas_coords = layer.get_cell_atlas_coords(map_coords)
		
		# If atlas_coords is NOT (-1, -1), a tile exists here
		if atlas_coords != Vector2i(-1, -1):
			return {
				"layer": layer,
				"map_coords": map_coords,
				"atlas_coords": atlas_coords
			}
	return {}

## Specific logic for when the mouse enters a new tile
func _on_tile_hover_entered(layer: TileMapLayer, map_coords: Vector2i, atlas_coords: Vector2i):
	if main_game_node.prespawned_structure:
		return
		
	tile_hovered.emit(layer, map_coords, atlas_coords)
	
	if main_game_node.have_a_villager_in_selection:
		# NOW CHECK IF THE THE MAP COORDINATES ARE CLOSE ENOUGH TO A VILLAGER
		var resource_global_position:Vector2 = to_global(layer.map_to_local(map_coords))
		var close_enough: bool = false
		
		for unit in selection_manager.selected_units:
			if unit:
				if resource_global_position.distance_squared_to(unit.global_position) < 2500:
					close_enough  = true
			
		if not close_enough:
			CursorManager.reset_cursor()
			over_left_clickable_tile = false
			return
			
		# Check if the NEW tile is special
		if atlas_coords in get_parent().trees_atlas_coords:
			CursorManager.set_cursor(CursorManager.Type.CHOP)
			over_left_clickable_tile = true
		elif atlas_coords in get_parent().mining_atlas_coords:
			CursorManager.set_cursor(CursorManager.Type.MINE)
			over_left_clickable_tile = true
		elif atlas_coords in get_parent().crop_atlas_coords:
			CursorManager.set_cursor(CursorManager.Type.HARVEST)
			over_left_clickable_tile = true
		else:
			# It's a valid tile, but not a special one (e.g., grass/dirt)
			# We must reset here so the cursor doesn't stay as an AXE
			CursorManager.reset_cursor()
			over_left_clickable_tile = false

@warning_ignore("unused_parameter")
func _on_tile_clicked(layer: TileMapLayer, map_coords: Vector2i, atlas_coords: Vector2i):
	# Check if the NEW tile is special and poppable
	var material_type: String
	if atlas_coords in get_parent().trees_atlas_coords:
		material_type = 'wood'
	elif atlas_coords == Vector2i(15,34):
		material_type = 'stone'
	elif atlas_coords == Vector2i(19,34):
		material_type = 'gold'
	elif atlas_coords in get_parent().crop_atlas_coords:
		material_type = 'food'
			
	if material_type:
		if main_game_node.have_a_villager_in_selection:
			# delete the tile
			layer.set_cell(map_coords, 0, Vector2i(-1,-1))
			# spawn a version of the tile as a PoppedTile
			var popped_tile = preload('res://scenes/entities/objects/popped_tile.tscn').instantiate()
			popped_tile.prepare(main_game_node.get_cropped_tile_texture(atlas_coords), material_type, 1)
			popped_tile.position = to_global(layer.map_to_local(map_coords))
			main_game_node.get_node('entities/objects').add_child(popped_tile, true)
	

## Specific logic for when the mouse leaves all tiles/layers
func _on_tile_hover_exited():
	# reset to default cursor
	CursorManager.reset_cursor()
