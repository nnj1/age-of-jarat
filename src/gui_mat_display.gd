extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func boost_mat_animation(mat_type:String):
	var icon = get_node_or_null(mat_type + 'texture')
	# Create the tween
	var tween = get_tree().create_tween()
	
	# 1. Scale up slightly with a "Back" ease for that springy feel
	tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# 2. Scale back to original size
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_LINEAR)
