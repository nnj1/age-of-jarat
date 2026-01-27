extends Node

@onready var lore: Dictionary = load_with_resource_loader('res://lore/lore.json')

# LOADERS
func load_with_resource_loader(path: String):
	# ResourceLoader.load() returns a JSON resource object
	var json_res = ResourceLoader.load(path) as JSON
	
	if json_res:
		var data = json_res.data # This is your Dictionary or Array
		#print("Loaded Data: ", data)
		return data
	else:
		print("Failed to load JSON resource.")
		return null
		
# FILTERS
## Filters a list of Dictionaries/Objects based on a key-value pair
func filter_json_objects(data: Array, key: String, target_value: Variant) -> Array:
	# .filter() creates a new array containing only the items that return 'true'
	return data.filter(
		func(item): 
			# Check if the key exists and matches the value
			return item.has(key) and item[key] == target_value
	)

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
