extends Unit

class_name Animal

func prepare(spawning_player_id: int = 1, given_faction:int = -1, given_lore_data=null):
	# animal sprites are located here:
	sprite_atlas_coords_corners = [
		Vector2i(1,14),
		Vector2i(10,16)
	]
	# NPCs like animals are -1 faction
	super.prepare(spawning_player_id, given_faction, given_lore_data)
	
func _ready():
	super._ready()
	
