extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if 'faction' in get_parent():
		$Label.text = str(get_parent().faction)
