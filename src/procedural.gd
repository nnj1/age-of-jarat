extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

# 1. References to your TileMapLayer nodes
# Ensure these names match your Scene Tree exactly
@onready var seabed_layer: TileMapLayer = $seabed
@onready var water_layer: TileMapLayer = $water
@onready var ground_layer: TileMapLayer = $ground
@onready var decorator_layer: TileMapLayer = $decorators
@onready var roads_layer: TileMapLayer = $roads
@onready var fow_layer: TileMapLayer = $fow

# 2. Atlas Coordinates (From your original setup)
var ground_atlas_coords = [Vector2i(0,7), Vector2i(1,7), Vector2i(2,7)]
var water_atlas_coords = [Vector2i(9,41)]
var sand_atlas_coords = [Vector2i(18,6)]
var seabed_atlas_coords = [Vector2i(5,13), Vector2i(3,7)]
var grass_atlas_coords = [Vector2i(3,9), Vector2i(4,9)]
var trees_atlas_coords = [Vector2i(0,34), Vector2i(1,34), Vector2i(2,34), Vector2i(3,34)]
var rock_atlas_coords = [Vector2i(10,5), Vector2i(11,5), Vector2i(12,5)]
var mining_atlas_coords = [Vector2i(15,34), Vector2i(15,34), Vector2i(15,34), Vector2i(19,34)]
var housing_atlas_coords = [Vector2i(1,33), Vector2i(2,33), Vector2i(3,33), Vector2i(4,33), Vector2i(5,33), Vector2i(6,33), Vector2i(7,33), Vector2i(8,33), Vector2i(9,33), Vector2i(10,33), Vector2i(11,33), Vector2i(12,33)]
var tilled_dirt_coords = [Vector2i(11,34)]
var crop_atlas_coords = [Vector2i(0, 24), Vector2i(1, 24), Vector2i(5, 24), Vector2i(6, 24)] # Example crop tiles

var road_h = [Vector2i(2, 11), Vector2i(3,11)] # Your horizontal road tile
var road_v = [Vector2i(0, 11), Vector2i(1,11)] # Your vertical road tile
var road_cross = Vector2i(12, 11) # Optional: A 4-way intersection tile
var paveable_points: Array[Vector2i]
var road_mask = {}

# 3. Generation Settings
@export var map_size: Vector2i = Vector2i(200, 200)
@export var noise_frequency: float = 0.04  # Lower = larger islands, Higher = noisier/smaller patches
@export var noise: FastNoiseLite = FastNoiseLite.new()
# Add a second noise generator
@export var vegetation_noise = FastNoiseLite.new()
@export var vegetation_noise_frequency = 0.08
@export var stone_noise = FastNoiseLite.new()
@export var stone_noise_frequency = 0.08

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
	vegetation_noise.seed = randi() + 1
	vegetation_noise.seed = randi() + 2
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
			var n2 = vegetation_noise.get_noise_2d(float(x), float(y))
			var n3 = stone_noise.get_noise_2d(float(x), float(y))
			
			determine_tiles(pos, n, n2, n3)
			
			counter += 1
			# print occasional progress updates
			if (x*y % 10000) == 0:
				print('Generation map...' + str(int(float(counter)/float(map_size.x * map_size.y) * 100.0)) +'%')
	
	prepare_road_mask(paveable_points)
	var road_density = randi_range(25, 75) # Generate between 5 and 12 roads
	generate_random_roads(road_density)
	
func determine_tiles(pos: Vector2i, noise_val: float, noise_val_2: float, noise_val_3: float) -> void:
	
	# set up the fog of war
	fow_layer.set_cell(pos, 0, seabed_atlas_coords[1])
	
	var on_solid_ground = false
	
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
		on_solid_ground = true
		# Grass
		if randf() > 0.70:
			decorator_layer.set_cell(pos, 0, grass_atlas_coords.pick_random())
			# if no grass maybe spawn an animal:
		elif randf() > 0.99:
			main_game_node.spawn_animal(to_global(ground_layer.map_to_local(pos)))
			
	else:
		# Rock Biome (will contain houses and village structures)
		ground_layer.set_cell(pos, 0, rock_atlas_coords.pick_random())
		var paveable:bool = true
		if noise_val_3 > -0.4:
			decorator_layer.set_cell(pos, 0, housing_atlas_coords.pick_random())
			paveable = false
		if noise_val_2 > 0.0:
			ground_layer.set_cell(pos, 0, tilled_dirt_coords.pick_random())
			paveable = false
			# scatter crops
			if randf() > 0.75: 
				decorator_layer.set_cell(pos, 0, crop_atlas_coords.pick_random())
				
		# save region for possible road
		if paveable:
			paveable_points.append(pos)
		
	if on_solid_ground:
		# handle vegetation (forests)
		if noise_val_2 > 0.0:
			decorator_layer.set_cell(pos, 0, trees_atlas_coords.pick_random())
		# handle minable resources (stone and gold)
		elif noise_val_3 > -0.4:
			decorator_layer.set_cell(pos, 0, mining_atlas_coords.pick_random())

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

## functions that handles paving the roads
func create_road_on_mask(start: Vector2i, end: Vector2i) -> void:
	var current = start
	var axis_is_x = randf() > 0.5
	
	var max_iterations = 20 # Safety cap for how many "turns" a road can make
	
	for i in range(max_iterations):
		if current == end: break
		
		# 1. Determine how far we want to go in a straight line
		var distance = randi_range(4, 10) # Minimum 4 tiles straight to prevent "clumping"
		
		# 2. Draw the segment
		for s in range(distance):
			if current == end: break
			
			# Move
			if axis_is_x:
				if current.x == end.x: break # Reached x limit
				current.x += 1 if end.x > current.x else -1
			else:
				if current.y == end.y: break # Reached y limit
				current.y += 1 if end.y > current.y else -1
				
			# 3. Place Tile with check
			if is_point_valid(current):
				_place_road_safely(current, axis_is_x)
		
		# 4. Flip Axis for the next segment
		axis_is_x = !axis_is_x

func _place_road_safely(p: Vector2i, moving_on_x: bool):
	var existing = roads_layer.get_cell_atlas_coords(p)
	
	# If there is already a tile here that isn't what we are currently drawing, 
	# it's an intersection or a corner.
	if existing != Vector2i(-1, -1):
		roads_layer.set_cell(p, 0, road_cross)
	else:
		var tile = road_h.pick_random() if moving_on_x else road_v.pick_random()
		roads_layer.set_cell(p, 0, tile)
		
func prepare_road_mask(points_array: Array):
	for p in points_array:
		road_mask[p] = true

func is_point_valid(p: Vector2i) -> bool:
	return road_mask.has(p)

func generate_random_roads(count: int):
	if paveable_points.is_empty():
		return

	# 1. Pick a "Central Hub" to start from
	var main_hub = paveable_points.pick_random()
	
	# 2. Generate 'count' number of roads
	for i in range(count):
		# Pick a random destination from your valid points
		var destination = paveable_points.pick_random()
		
		# Choose which road style to draw:
		# Use the mask function so roads only appear on valid tiles
		create_road_on_mask(main_hub, destination)
		
		# Optional: Make the new destination a new potential start point 
		# This creates "branching" roads rather than just a star shape
		if randf() > 0.5:
			main_hub = destination

## Returns the world-space boundaries of the generated map
func get_map_bounds() -> Rect2:
	# 1. Calculate the total size in pixels
	# We use 12.0 here because your code uses 12.0 for the centering math
	var tile_size = 12.0 
	var width_px = map_size.x * tile_size
	var height_px = map_size.y * tile_size
	
	# 2. Get the top-left corner based on your centering logic in _ready()
	# Since you centered it, the top-left is: self.position
	var top_left = self.global_position
	
	return Rect2(top_left.x, top_left.y, width_px, height_px)
