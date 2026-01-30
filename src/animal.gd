extends Unit

class_name Animal

@warning_ignore("unused_parameter")
func prepare(spawning_player_id: int = 1, given_faction: int = -1, given_lore_data = null, given_unit_type = null):
	# NPCs like animals are -1 faction
	super.prepare(spawning_player_id, given_faction, given_lore_data, given_unit_type)
	
	
func _ready():
	super._ready()
	
