extends Node2D

@export var is_human:bool = true
@export var hit_sound_stream: AudioStream
@export var hurt_sound_stream: AudioStream
@export var spawn_sound_stream: AudioStream
@export var walking_sound_stream: AudioStream
@export var idle_sound_stream: AudioStream
@export var death_sound_stream: AudioStream
@export var building_sound_stream: AudioStream
@export var build_complete_sound_stream: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# set the streams
	$hitSound.stream = hit_sound_stream
	$hurtSound.stream= hurt_sound_stream
	$spawnSound.stream = spawn_sound_stream
	$walkingSound.stream = walking_sound_stream
	$idleSound.stream = idle_sound_stream
	$deathSound.stream = death_sound_stream
	$buildCompleteSound.stream = build_complete_sound_stream
	$buildingSound.stream = building_sound_stream
	
	if is_human:
		$spawnSound.stream = MusicManager.spawn_streams.pick_random()
	$spawnSound.play()
	
	# start random idle sound
	$idleSound/Timer.start(randf_range(3, 10))

func _on_timer_timeout() -> void:
	if is_human:
		$idleSound.stream = MusicManager.idle_streams.pick_random()
	$idleSound.play()
	# set new interval
	$idleSound/Timer.start(randf_range(3, 10))

func play_attack_grunt() -> void:
	if is_human:
		$hitSound.stream = MusicManager.grunt_streams.pick_random()
	$hitSound.play()
	
func play_hurt_sound() -> void:
	if is_human:
		$hurtSound.stream = MusicManager.damage_streams.pick_random()
	$hurtSound.play()

func play_death_sound() -> void:
	if is_human:
		$deathSound.stream = MusicManager.damage_streams.pick_random()
	$deathSound.play()
