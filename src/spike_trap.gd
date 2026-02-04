extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# modify the parent's collision so units can walk over this structure
	var parent_generic_structure : StaticBody2D = get_parent().get_parent()
	parent_generic_structure.set_collision_mask_value(2, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
