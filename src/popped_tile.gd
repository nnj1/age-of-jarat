extends Node2D

@onready var map_interaction_component = get_tree().get_first_node_in_group('map_interaction_component')

@export_group("Movement")
@export var speed: float = 200.0
@export var arrival_threshold: float = 5.0

@export_group("Visuals")
## The normal size of the tile after popping.
@export var base_scale: float = 0.5
## how large the tile gets during the "pop" overshoot.
@export var max_pop_scale: float = 0.6
## How high the tile bounces during the idle animation.
@export var bounce_height: float = 5.0
## Duration of the bounce cycle.
@export var bounce_speed: float = 0.4

@onready var sprite: Sprite2D = $Sprite2D

var target_villager: Node2D = null
@export var is_collecting: bool = false
@export var material_type: String:
	set(value):
		material_type = value
		# If the node is ready, update visuals immediately when the value arrives
		if is_node_ready():
			load_visuals()
			
@export var material_amount: int
var faction_that_mined: int

@onready var main_game_node = get_tree().get_root().get_node('Game')

func prepare(given_material_type: String, given_material_amount: int, tile_texture: Texture2D) -> void:
	var s = $Sprite2D
	s.texture = tile_texture
	# Start at zero for the pop effect
	s.scale = Vector2.ZERO 
	
	material_type = given_material_type
	material_amount = given_material_amount
	
func load_visuals():
	var s = $Sprite2D
	if map_interaction_component.default_material_textures:
		s.texture = map_interaction_component.default_material_textures[material_type]
		# Start at zero for the pop effect
	s.scale = Vector2.ZERO 
	
func _ready() -> void:
	play_spawn_effects()
	if not multiplayer.is_server():
		load_visuals()
	
func _process(delta: float) -> void:
	if not multiplayer.is_server(): return
	
	if is_collecting or target_villager == null:
		return

	if is_instance_valid(target_villager):
		var direction = global_position.direction_to(target_villager.global_position)
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_villager.global_position) < arrival_threshold:
			finalize_collection()
	else:
		target_villager = null

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("villagers") and target_villager == null:
		# only faction associated body can pick up the item
		if body.faction == faction_that_mined: 
			target_villager = body

## --- Visual Animations ---

func play_spawn_effects() -> void:
	var tween = create_tween().set_parallel(false)
	
	# Scale up to Max Scale
	tween.tween_property(sprite, "scale", Vector2(max_pop_scale, max_pop_scale), 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# Settle to Base Scale
	tween.tween_property(sprite, "scale", Vector2(base_scale, base_scale), 0.1)
	
	tween.finished.connect(start_idle_bounce)

func start_idle_bounce() -> void:
	var tween = create_tween().set_loops()
	# Upward movement
	tween.tween_property(sprite, "position:y", -bounce_height, bounce_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	# Downward movement
	tween.tween_property(sprite, "position:y", 0, bounce_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

func finalize_collection() -> void:
	if is_collecting: return
	is_collecting = true
	
	var tween = create_tween()
	# Shrink from current scale down to zero
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.finished.connect(destroy)

func destroy():
	main_game_node.call('add_' + material_type, material_amount)
	# TODO: ADD THE MATERIAL TO THE CLIENT
	queue_free()
