extends Unit

func prepare(spawning_player_id: int = 1):
	# warrior sprites are located here:
	sprite_atlas_coords_corners = [
		Vector2i(179,16),
		Vector2i(185,19)
	]
	super.prepare(spawning_player_id)
	
func _ready():
	# Connect important combat signals
	$RangeAttackComponent.just_range_attacked.connect($SoundComponent.play_attack_grunt)
	
	super._ready()
	
