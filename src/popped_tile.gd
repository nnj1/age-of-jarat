extends Node2D

@export var speed: float = 200.0
@export var arrival_threshold: float = 5.0

@onready var sprite: Sprite2D = $Sprite2D

var target_villager: Node2D = null
var is_collecting: bool = false

var material_type: String
var material_amount: int

@onready var main_game_node = get_tree().get_root().get_node('Game')


## Called immediately after instantiation to set the tile look
func prepare(tile_texture: Texture2D, given_material_type: String, given_material_amount:int = 1) -> void:
	# Using $ directly because @onready hasn't fired yet
	var s = $Sprite2D
	s.texture = tile_texture
	s.scale = Vector2.ZERO # Start at zero for the "pop" effect
	
	material_type = given_material_type
	material_amount = given_material_amount
	
func _ready() -> void:
	find_closest_villager()
	play_spawn_effects()

func _process(delta: float) -> void:
	if is_collecting:
		return

	if is_instance_valid(target_villager):
		# Move toward the villager
		var direction = global_position.direction_to(target_villager.global_position)
		global_position += direction * speed * delta
		
		# Check for arrival
		if global_position.distance_to(target_villager.global_position) < arrival_threshold:
			finalize_collection()
	else:
		# Keep looking for a villager if the target is lost
		find_closest_villager()

func find_closest_villager() -> void:
	var villagers = get_tree().get_nodes_in_group("villagers")
	var closest_dist = INF
	
	for villager in villagers:
		var dist = global_position.distance_to(villager.global_position)
		if dist < closest_dist:
			closest_dist = dist
			target_villager = villager

func play_spawn_effects() -> void:
	var tween = create_tween().set_parallel(false)
	
	# 1. The Juice: Scale up with a bouncy overshoot
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# 2. Settle to normal size
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
	
	# 3. Start the infinite idle bounce once the pop is done
	tween.finished.connect(start_idle_bounce)

func start_idle_bounce() -> void:
	var tween = create_tween().set_loops()
	# Animates the sprite locally so it doesn't break the global movement
	tween.tween_property(sprite, "position:y", -10, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", 0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

func finalize_collection() -> void:
	if is_collecting: return
	is_collecting = true
	
	# Quick shrink effect when hitting the villager
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.finished.connect(destroy)

func destroy():
	main_game_node.call('add_' + material_type, material_amount)
	queue_free()
