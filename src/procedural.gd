extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

# 1. References to your TileMapLayer nodes
# Ensure these names match your Scene Tree exactly
@onready var seabed_layer: TileMapLayer = $seabed
@onready var water_layer: TileMapLayer = $water
@onready var ground_layer: TileMapLayer = $ground
@onready var decorator_layer: TileMapLayer = $decorators
@onready var fow_layer: TileMapLayer = $fow

# 2. Atlas Coordinates (From your original setup)
var ground_atlas_coords = [Vector2i(0,7), Vector2i(1,7), Vector2i(2,7)]
var water_atlas_coords = [Vector2i(9,41)]
var sand_atlas_coords = [Vector2i(18,6)]
var seabed_atlas_coords = [Vector2i(5,13), Vector2i(3,7)]
var grass_atlas_coords = [Vector2i(3,9), Vector2i(4,9)]
var trees_atlas_coords = [Vector2i(0,34), Vector2i(1,34), Vector2i(2,34), Vector2i(3,34)]
var rock_atlas_coords = [Vector2i(10,5), Vector2i(11,5), Vector2i(12,5)]

# 3. Generation Settings
@export var map_size: Vector2i = Vector2i(100, 100)
@export var noise_frequency: float = 0.04  # Lower = larger islands, Higher = noisier/smaller patches
@export var noise: FastNoiseLite = FastNoiseLite.new()

# 4. FOW Settings
@export var vision_radius: int = 8
var update_timer: float = 0.0
var update_interval: float = 0.15 # Update ~6 times per second (good for performance)

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_fow_for_all_units()

func _ready() -> void:
	
	# ADD THIS: Register this node as the FogSystem
	add_to_group("FogSystem")
	
	# OPTIONAL: center the map
	self.position -= Vector2(map_size.x * 12.0 / 2, map_size.y * 12.0 / 2)
	
	# Initialize random seed and noise settings
	randomize()
	noise.seed = randi()
	#noise.frequency = noise_frequency
	#noise.noise_type = FastNoiseLite.TYPE_PERLIN # Organic, smooth transitions
	
	generate_world()
	
# --- NEW FOG SYSTEM INTERFACE ---

## This is the function the Units/WanderComponent will call
func is_pos_revealed(world_pos: Vector2) -> bool:
	# 1. Convert global world position to the tilemap's internal grid coordinates
	var map_pos = fow_layer.local_to_map(fow_layer.to_local(world_pos))
	
	# 2. Check if a tile exists at that spot on the fog layer
	# get_cell_source_id returns -1 if the cell is empty (erased)
	var tile_id = fow_layer.get_cell_source_id(map_pos)
	
	# 3. If tile_id is -1, the fog has been erased (Revealed)
	return tile_id == -1

func generate_world() -> void:
	# Clear existing tiles before generating
	ground_layer.clear()
	decorator_layer.clear()
	
	var counter = 0
	for x in range(map_size.x):
		for y in range(map_size.y):
			var pos = Vector2i(x, y)
			# get_noise_2d returns a value between -1.0 and 1.0
			var n = noise.get_noise_2d(float(x), float(y))
			
			determine_tiles(pos, n)
			
			counter += 1
			# print occasional progress updates
			if (x*y % 10000) == 0:
				print('Generation map...' + str(int(float(counter)/float(map_size.x * map_size.y) * 100.0)) +'%')

func determine_tiles(pos: Vector2i, noise_val: float) -> void:
	
	# set up the fog of war
	fow_layer.set_cell(pos, 0, seabed_atlas_coords[1])
	
	# Thresholds determine the "elevation" or biome
	if noise_val < -0.1:
		# Water Biome
		seabed_layer.set_cell(pos, 0, seabed_atlas_coords.pick_random())
		water_layer.set_cell(pos, 0, water_atlas_coords.pick_random())
	elif noise_val < -0.075:
		# sand/beach biome
		seabed_layer.set_cell(pos, 0, seabed_atlas_coords.pick_random())
		ground_layer.set_cell(pos, 0, sand_atlas_coords.pick_random())
	elif noise_val < 0.2:
		# Ground/Dirt Biome
		ground_layer.set_cell(pos, 0, ground_atlas_coords.pick_random())
		# Grass or tree
		if randf() > 0.70:
			decorator_layer.set_cell(pos, 0, grass_atlas_coords.pick_random())
			if randf() > 0.50:
				decorator_layer.set_cell(pos, 0, trees_atlas_coords.pick_random())
		# if no grass or tree, maybe spawn an animal:
		elif randf() > 0.99:
			main_game_node.spawn_animal(to_global(ground_layer.map_to_local(pos)))
			
	else:
		# Rock Biome
		ground_layer.set_cell(pos, 0, rock_atlas_coords.pick_random())
		# High chance of trees (Forest)
		#if randf() > 0.82:
		#	decorator_layer.set_cell(pos, 0, trees_atlas_coords.pick_random())

func update_fow_for_all_units() -> void:
	var units = get_tree().get_nodes_in_group("units")
	
	for unit in units:
		var unit_tile = fow_layer.local_to_map(fow_layer.to_local(unit.global_position))
		reveal_area(unit_tile)

func reveal_area(center: Vector2i) -> void:
	# Optimization: Only check tiles within the vision box
	for x in range(-vision_radius, vision_radius + 1):
		for y in range(-vision_radius, vision_radius + 1):
			var target = center + Vector2i(x, y)
			
			# Check distance for circular vision
			if center.distance_to(target) < vision_radius:
				# erase_cell is permanent "Exploration"
				fow_layer.erase_cell(target)
