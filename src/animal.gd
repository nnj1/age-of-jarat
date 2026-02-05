extends Unit

class_name Animal

@warning_ignore("unused_parameter")
func prepare(given_spawning_player_id: int = 1, given_faction: int = -1, given_lore_data = null, given_unit_type = null):
	# NPCs like animals are -1 faction
	super.prepare(given_spawning_player_id, given_faction, given_lore_data, given_unit_type)
	
func on_death():
	#spawn some meat
	var popped_tile = preload('res://scenes/entities/objects/popped_tile.tscn').instantiate()
	popped_tile.prepare('food', randi_range(1, 5), main_game_node.get_cropped_tile_texture(Vector2i(1,17)))
	popped_tile.position = self.global_position
	main_game_node.get_node('entities/objects').call_deferred('add_child', popped_tile, true)
	super.on_death()
	
