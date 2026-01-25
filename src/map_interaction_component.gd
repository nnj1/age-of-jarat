extends Node2D # Or whatever parent node holds your layers

signal tile_pressed(layer_node, map_coords, atlas_coords)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Get all children that are TileMapLayers
		var layers = get_parent().get_children().filter(func(node): return node is TileMapLayer)
		
		# Reverse the list so we check the "top" visual layer first
		layers.reverse()
		
		for layer in layers:
			var local_pos = layer.to_local(get_global_mouse_position())
			var map_coords = layer.local_to_map(local_pos)
			var atlas_coords = layer.get_cell_atlas_coords(map_coords)
			
			# Vector2i(-1, -1) means "no tile here"
			if atlas_coords != Vector2i(-1, -1):
				tile_pressed.emit(layer, map_coords, atlas_coords)
				print("Clicked layer: ", layer.name, " Atlas Coords: ", atlas_coords)
				
				# Stop the loop if you only want to click the top-most tile
				get_viewport().set_input_as_handled()
				break
