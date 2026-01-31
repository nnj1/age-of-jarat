extends Node2D

@export var speed: float = 200.0
@export var arrival_threshold: float = 5.0

@onready var sprite: Sprite2D = $Sprite2D

var target_villager: Node2D = null
var is_collecting: bool = false

var material_type: String
var material_amount: int

@onready var main_game_node = get_tree().get_root().get_node('Game')

func prepare(tile_texture: Texture2D, given_material_type: String, given_material_amount:int = 1) -> void:
	var s = $Sprite2D
	s.texture = tile_texture
	s.scale = Vector2.ZERO 
	
	material_type = given_material_type
	material_amount = given_material_amount
	
func _ready() -> void:
	# We no longer call find_closest_villager() here. 
	# The tile stays put until someone walks near it.
	play_spawn_effects()

func _process(delta: float) -> void:
	if is_collecting or target_villager == null:
		return

	if is_instance_valid(target_villager):
		var direction = global_position.direction_to(target_villager.global_position)
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_villager.global_position) < arrival_threshold:
			finalize_collection()
	else:
		# If the villager leaves or dies, stop moving
		target_villager = null

## --- Signal Handlers for Area2D ---

# Connect this signal from your Area2D in the editor
func _on_detection_area_body_entered(body: Node2D) -> void:
	# Only target if it's a villager and we don't already have a target
	if body.is_in_group("villagers") and target_villager == null:
		target_villager = body

## --- Visuals and Collection ---

func play_spawn_effects() -> void:
	var tween = create_tween().set_parallel(false)
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
	tween.finished.connect(start_idle_bounce)

func start_idle_bounce() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -10, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func finalize_collection() -> void:
	if is_collecting: return
	is_collecting = true
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(destroy)

func destroy():
	main_game_node.call('add_' + material_type, material_amount)
	queue_free()
