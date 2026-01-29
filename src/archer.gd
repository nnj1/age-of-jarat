extends Unit
	
func _ready():
	# Connect important combat signals
	$RangeAttackComponent.just_range_attacked.connect($SoundComponent.play_attack_grunt)
	
	super._ready()
	
