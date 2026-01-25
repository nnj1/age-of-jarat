extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$spawnSound.stream = MusicManager.spawn_streams.pick_random()
	$spawnSound.play()
	
	# start random idle sound
	$idleSound/Timer.start(randf_range(3, 10))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	$idleSound.stream = MusicManager.idle_streams.pick_random()
	$idleSound.play()
	# set new interval
	$idleSound/Timer.start(randf_range(3, 10))

func play_attack_grunt() -> void:
	$hitSound.stream = MusicManager.grunt_streams.pick_random()
	$hitSound.play()
	
func play_hurt_sound() -> void:
	$hurtSound.stream = MusicManager.damage_streams.pick_random()
	$hurtSound.play()

func play_death_sound() -> void:
	$deathSound.stream = MusicManager.damage_streams.pick_random()
	$deathSound.play()
