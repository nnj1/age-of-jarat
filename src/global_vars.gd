extends Node

# BASIC MATH FUNCTIONS AND SHIT

func get_vectors_in_range(p1: Vector2i, p2: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	# Create a Rect2i from two points. 
	# abs() ensures it works even if p2 is "behind" p1.
	var rect = Rect2i(p1, Vector2i.ZERO).expand(p2)
	
	# Loop through the X and Y range
	# We use rect.end + 1 if you want the border included
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			points.append(Vector2i(x, y))
			
	return points
