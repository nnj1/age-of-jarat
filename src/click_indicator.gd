extends Sprite2D


func _ready():
	var scale_target = self.scale * 1
	# 1. Create the tween
	var tween = create_tween()
	
	# 2. Set it to run scale and fade at the same time
	tween.set_parallel(true)
	
	# 3. Animate (Target, Property, Final Value, Duration)
	tween.tween_property(self, "scale", scale_target, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	# 4. Automatically delete the indicator when the tween finishes
	tween.finished.connect(queue_free)
