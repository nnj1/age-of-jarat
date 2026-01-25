extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/Panel2/Minimap/SubViewport.world_2d = get_tree().root.get_viewport().world_2d
	
	$map/procedural/MapInteractionComponent.tile_pressed.connect(update_object_menu)

func _process(_delta: float) -> void:
	# Get the FPS
	var fps = Engine.get_frames_per_second()
	
	# Get the current Date and Time
	var datetime = Time.get_datetime_dict_from_system()
	
	# Format the string
	# %02d ensures leading zeros (e.g., 09 instead of 9)
	var time_string = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
	var date_string = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]
	
	# Update the label text
	$UI/Label.text = "FPS: %d | Date: %s | Time: %s" % [fps, date_string, time_string]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_V:
			spawn_villager(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_W:
			spawn_warrior(get_global_mouse_position())

func spawn_villager(spawn_pos: Vector2):
	var villager = preload("res://scenes/entities/units/villager.tscn").instantiate()
	villager.prepare(1)
	villager.position = spawn_pos
	$entities/units.add_child(villager, true)
	
func spawn_warrior(spawn_pos: Vector2):
	var warrior = preload("res://scenes/entities/units/warrior.tscn").instantiate()
	warrior.prepare(1)
	warrior.position = spawn_pos
	$entities/units.add_child(warrior, true)

@warning_ignore("unused_parameter")
func update_object_menu(layer_node, map_coords, atlas_coords):
	for child in $UI/TabContainer/Object.get_children():
		child.queue_free()
		
	# 2. Create the Label
	var label = Label.new()
	label.text = "Atlas: " + str(atlas_coords)
	
	# Center the label inside the panel
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# 3. Add Label to Panel, and Panel to the Scene
	$UI/TabContainer/Object.add_child(label)
