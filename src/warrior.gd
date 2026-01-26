extends Unit

func prepare(spawning_player_id: int = 1, given_faction:int = randi_range(0, 1)):
	# warrior sprites are located here:
	sprite_atlas_coords_corners = [
		Vector2i(179,16),
		Vector2i(185,19)
	]
	super.prepare(spawning_player_id, given_faction)
	
func _ready():
	# Connect important combat signals
	$MeleeAttackComponent.just_melee_attacked.connect($SoundComponent.play_attack_grunt)
	
	super._ready()
	
