extends Node2D

@onready var collision_shape: CollisionShape2D = get_parent().get_node('CollisionShape2D')

var tile_layer: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create a collision layer based on tier 1 sprite
	tile_layer = $'1'
	update_collision_to_layer()

func update_collision_to_layer() -> void:
	var used_cells = tile_layer.get_used_cells()
	
	if used_cells.is_empty():
		collision_shape.disabled = true
		return
	
	collision_shape.disabled = false
	
	# 1. Find the bounding box of the used cells (in grid coordinates)
	var rect = tile_layer.get_used_rect()
	
	# 2. Convert grid coordinates to local pixel coordinates
	# get_used_rect() returns position (top-left cell) and size (how many cells)
	var tile_size = tile_layer.tile_set.tile_size
	
	# Calculate the pixel size and center
	var pixel_size = Vector2(rect.size) * Vector2(tile_size)
	var pixel_center = (Vector2(rect.position) * Vector2(tile_size)) + (pixel_size / 2.0)
	
	# 3. Apply to the CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = pixel_size
	
	collision_shape.shape = shape
	collision_shape.position = pixel_center
