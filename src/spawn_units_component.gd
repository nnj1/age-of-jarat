extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

# variables governing spawnables
var unit_spawn_queue: Array[Dictionary]
var max_unit_spawn_queue_size: int = 5
@onready var spawn_position_marker = $spawn_position_marker
@onready var spawn_queue_count_label = $spawn_queue_count_label
var wait_duration: float = 0.0
var time_passed_for_unit_spawning: float = 0.0

@onready var loading_material_shader = $loading.material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().done_building:
		# actual logic for spawning units here
		if unit_spawn_queue:
			spawn_queue_count_label.text = str(int(unit_spawn_queue.size()))
			var unit_lore_data = unit_spawn_queue[0]
			wait_duration = unit_lore_data.spawn_speed
			if time_passed_for_unit_spawning >= wait_duration:
				spawn_unit_from_lore_data(unit_lore_data)
				unit_spawn_queue.pop_front()
				time_passed_for_unit_spawning = 0.0
				wait_duration = 0.0
			time_passed_for_unit_spawning += delta
		
		# update the progress timer
		if wait_duration != 0.0:
			loading_material_shader.set_shader_parameter('progress', time_passed_for_unit_spawning/wait_duration)
		

## stuff regarding unit spawning
func add_new_unit_to_queue(unit_name:String):
	if unit_spawn_queue.size() <= max_unit_spawn_queue_size:
		if unit_name in get_parent().lore_data.tiers[str(int(get_parent().current_tier))].spawnable_units:
			var unit_lore_data = GlobalVars.filter_json_objects(GlobalVars.lore.units, 'name', unit_name)[0]
			unit_spawn_queue.append(unit_lore_data)
			print('added guy to spawn queue')
			
func spawn_unit_from_lore_data(unit_lore_data: Dictionary):
	main_game_node.call('spawn_' + unit_lore_data['type'], spawn_position_marker.global_position, unit_lore_data)
	print('spawned this guy')
