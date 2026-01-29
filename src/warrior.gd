extends Unit

func _ready():
	# Connect important combat signals
	$MeleeAttackComponent.just_melee_attacked.connect($SoundComponent.play_attack_grunt)
	
	super._ready()
	
