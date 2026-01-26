extends Node2D

var materials = {
	'food': 0,
	'wood': 0,
	'stone': 0,
	'gold': 0
}

var alt_held: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the minimap to share the world
	$UI/Panel2/Minimap/SubViewport.world_2d = get_tree().root.get_viewport().world_2d
	
	# connect important signals that update UI
	$map/procedural/MapInteractionComponent.tile_pressed.connect(update_object_menu)
	$SelectionManager.unit_just_added.connect(update_unit_menu)
	$SelectionManager.selected_units_changed.connect(update_selection_menu)
	
	# HIDE UNIT TAB BY DEFAULT
	set_tab_hidden_by_name($UI/TabContainer, 'Unit', true)
	
	

func _process(_delta: float) -> void:
	
	# determine if alt is being pressed
	alt_held = true if Input.is_key_pressed(KEY_ALT) else false
		
	# Get the FPS
	var fps = Engine.get_frames_per_second()
	
	# Get the current Date and Time
	var datetime = Time.get_datetime_dict_from_system()
	
	# Format the string
	# %02d ensures leading zeros (e.g., 09 instead of 9)
	var time_string = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
	var date_string = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]
	
	# Update the label text
	$UI/VBoxContainer/Label.text = "FPS: %d | Date: %s | Time: %s" % [fps, date_string, time_string]
	
	# Update the materials UI
	update_material_display()
	
func update_material_display():
	for mat_name in materials.keys():
		get_node('UI/VBoxContainer/HBoxContainer/' + mat_name).text = str(materials[mat_name])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_V:
			spawn_villager(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_W:
			spawn_warrior(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_M:
			spawn_wizard(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_A:
			spawn_archer(get_global_mouse_position())
		if event.pressed and event.keycode == KEY_B:
			spawn_animal(get_global_mouse_position())
			
func spawn_villager(spawn_pos: Vector2):
	var villager = preload("res://scenes/entities/units/villager.tscn").instantiate()
	villager.prepare(1, 0 if not alt_held else 1)
	villager.position = spawn_pos
	$entities/units.add_child(villager, true)
	
func spawn_warrior(spawn_pos: Vector2):
	var warrior = preload("res://scenes/entities/units/warrior.tscn").instantiate()
	warrior.prepare(1, 0 if not alt_held else 1)
	warrior.position = spawn_pos
	$entities/units.add_child(warrior, true)

func spawn_archer(spawn_pos: Vector2):
	var archer = preload("res://scenes/entities/units/archer.tscn").instantiate()
	archer.prepare(1, 0 if not alt_held else 1)
	archer.position = spawn_pos
	$entities/units.add_child(archer, true)
	
func spawn_wizard(spawn_pos: Vector2):
	var wizard = preload("res://scenes/entities/units/wizard.tscn").instantiate()
	wizard.prepare(1, 0 if not alt_held else 1)
	wizard.position = spawn_pos
	$entities/units.add_child(wizard, true)

func spawn_animal(spawn_pos: Vector2):
	var animal = preload("res://scenes/entities/npcs/animal.tscn").instantiate()
	animal.prepare()
	animal.position = spawn_pos
	$entities/npcs.add_child(animal, true)

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

func update_selection_menu(selected_units):
	for child in $UI/TabContainer/Selection/HBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	for unit in selected_units:
		# 1. Create the TextureRect instance
		var new_tex_rect = TextureRect.new()
		# 2. Load and assign the texture
		new_tex_rect.texture = get_cropped_tile_texture(unit.random_atlas_coords)
		
		# 3. Configure sizing (Crucial for GridContainers)
		# This ensures the texture actually fills the grid cell
		new_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Set a minimum size so the GridContainer knows how to layout
		new_tex_rect.custom_minimum_size = Vector2(40, 40)
		new_tex_rect.tooltip_text = str(unit.name)
		
		# 4. Add it to the GridContainer (self)
		$UI/TabContainer/Selection/HBoxContainer/ScrollContainer/GridContainer.add_child(new_tex_rect)

func update_unit_menu(unit):
	# SHOW THE TAB
	set_tab_hidden_by_name($UI/TabContainer, 'Unit', false)
	#$UI/TabContainer/Unit.show()
	
	# set up some references for easy access later
	var delete_button = $UI/TabContainer/Unit/HBoxContainer/VBoxContainer2/Button4
	
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer/Label.text = str(unit.name)
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer/RichTextLabel.text = str(unit.random_atlas_coords)
	$UI/TabContainer/Unit/HBoxContainer/TextureRect.texture = get_cropped_tile_texture(unit.random_atlas_coords)
	
	var delete_unit = func():
		if unit:
			if 'on_death' in unit:
				unit.on_death()
				# HIDE THE TAB if unit is deleted
				set_tab_hidden_by_name($UI/TabContainer, 'Unit', true)
	
	# Connect signal to button after clearing prior signals
	for connection in delete_button.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	delete_button.pressed.connect(delete_unit)
	
func get_cropped_tile_texture(atlas_coords: Vector2i) -> AtlasTexture:
	var source = preload('res://resources/urizen.tres').get_source(0) as TileSetAtlasSource
	
	if source:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = source.texture
		atlas_tex.region = source.get_tile_texture_region(atlas_coords)
		return atlas_tex
	return null

func set_tab_hidden_by_name(tab_container: TabContainer, tab_name: String, state: bool):
	for i in range(tab_container.get_tab_count()):
		if tab_container.get_tab_title(i) == tab_name:
			tab_container.set_tab_hidden(i, state)
			return

func exit_game_to_menu():
	#TODO: close any connections if server or host
	pass

func exit_game_to_desktop():
	#TODO: close any connections if server or host
	get_tree().quit()
