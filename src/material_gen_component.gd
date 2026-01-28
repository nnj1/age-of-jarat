extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')
@onready var parent_structure = get_parent()

# variables governing material spawn:
var time_passed: float = 0.0
@export var material_spawn_interval: float = 15.0

# animation stuff
@onready var textures = {
	'wood': main_game_node.get_cropped_tile_texture(Vector2i(0, 23)),
	'food': main_game_node.get_cropped_tile_texture(Vector2i(5, 17)),
	'gold': main_game_node.get_cropped_tile_texture(Vector2i(8, 46)),
	'stone': main_game_node.get_cropped_tile_texture(Vector2i(15, 34))
}
#const TRANSPARENT_BACKGROUND_SHADER = preload("res://shaders/transparentback.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# update the material quantities only if structure is built
	if parent_structure.done_building:
		time_passed += delta
		if time_passed >= material_spawn_interval:
			# Do material adjustment here
			if parent_structure:
				if 'generation' in parent_structure.lore_data.tiers[str(int(parent_structure.current_tier))]:
					var generation_obj = parent_structure.lore_data.tiers[str(int(parent_structure.current_tier))].generation
					for mat_type in generation_obj.keys():
						# TODO: CAN BE SIMPLIFIED
						if mat_type == 'wood':
							main_game_node.add_wood(int(generation_obj[mat_type]))
							spawn_floating_sprite(textures['wood'])
						elif mat_type == 'stone':
							main_game_node.add_stone(int(generation_obj[mat_type]))
							spawn_floating_sprite(textures['stone'])
						elif mat_type == 'gold':
							main_game_node.add_gold(int(generation_obj[mat_type]))
							spawn_floating_sprite(textures['gold'])
						elif mat_type == 'food':
							main_game_node.add_food(int(generation_obj[mat_type]))
							spawn_floating_sprite(textures['food'])
							
			time_passed = 0.0 # Reset the clock

func spawn_floating_sprite(texture: Texture2D, spawn_position: Vector2 = self.position):
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = spawn_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
	
	#var mat = ShaderMaterial.new()
	#mat.shader = TRANSPARENT_BACKGROUND_SHADER
	#sprite.material = mat
	
	sprite.z_index = 10
	
	add_child(sprite)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Transition is the 'shape' (Cubic), Ease is the 'direction' (Out)
	tween.tween_property(sprite, "position:y", sprite.position.y - 10, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
	
	tween.chain().tween_callback(sprite.queue_free)
