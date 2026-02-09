extends Node2D

## for optimization
var already_made_atlas_textures = {}

var materials = {
	'food': 0,
	'wood': 0,
	'stone': 0,
	'gold': 0
}

signal materials_changed

var unit_list: Array[Unit] # contains all the units in faction
var structure_list: Array[Structure] # contains all the structures in a faction
var have_a_villager_in_selection:bool = false # self explantory

var alt_held: bool = false # detects if alt key is held

var prespawned_structure:Structure # for drag and drop mechanic

## FOR BUILD MENU
@onready var option_button = $UI/TabContainer/Build/HBoxContainer/VBoxContainer/OptionButton

var time_passed: float = 0.0
var material_spawn_interval: float = 15.0

func _enter_tree() -> void:
	# set up unit spawner function
	$entities/units/MultiplayerSpawner.spawn_function = _on_unit_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# populate the option button
	for structure in GlobalVars.lore.structures:
		option_button.add_item(structure.name)
	# 1. Get the internal PopupMenu
	var popup = option_button.get_popup()
	# 2. Set the font size for the items in the dropdown
	popup.add_theme_font_size_override("font_size", 25)
		
	# get the minimap to share the world
	$UI/Panel2/Minimap/SubViewport.world_2d = get_tree().root.get_viewport().world_2d
	
	# connect important signals that update UI
	$map/procedural/MapInteractionComponent.tile_pressed.connect(update_object_menu)
	#$SelectionManager.unit_just_added.connect(update_unit_menu)
	$SelectionManager.selected_units_changed.connect(update_selection_menu)
	
	# conncet signal that updates state of a spawnable button if the materials amount changes
	materials_changed.connect(update_spawnable_buttons)
	
	# HIDE UNIT TAB BY DEFAULT
	set_tab_hidden_by_name($UI/TabContainer, 'Unit', true)
	# HIDE THE SELECTION TAB BY DEFAULT
	set_tab_hidden_by_name($UI/TabContainer, 'Selection', true)
	# HIDE THE SELECTION STRUCTURE BY DEFAULT
	set_tab_hidden_by_name($UI/TabContainer, 'Structure', true)

	# Spawn the first four villagers for the player!
	spawn_villager.rpc_id(1, $map/procedural.get_optimal_villager_start_position())
	spawn_villager.rpc_id(1, $map/procedural.get_optimal_villager_start_position())
	spawn_villager.rpc_id(1, $map/procedural.get_optimal_villager_start_position())
	spawn_villager.rpc_id(1, $map/procedural.get_optimal_villager_start_position())
	
# material incrementation functions
@rpc("any_peer","call_local","reliable")
func add_wood(amount: int = 1):
	materials.wood += amount
	$UI/VBoxContainer/GUIMatDisplay.boost_mat_animation('wood')
	materials_changed.emit()
@rpc("any_peer","call_local","reliable")
func add_stone(amount: int = 1):
	materials.stone += amount
	$UI/VBoxContainer/GUIMatDisplay.boost_mat_animation('stone')
	materials_changed.emit()
@rpc("any_peer","call_local","reliable")
func add_gold(amount: int = 1):
	materials.gold += amount
	$UI/VBoxContainer/GUIMatDisplay.boost_mat_animation('gold')
	materials_changed.emit()
@rpc("any_peer","call_local","reliable")
func add_food(amount: int = 1):
	materials.food += amount
	$UI/VBoxContainer/GUIMatDisplay.boost_mat_animation('food')
	materials_changed.emit()
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	
	# determine if alt is being pressed
	alt_held = true if Input.is_key_pressed(KEY_ALT) else false
		
	# Get the FPS
	var fps = Engine.get_frames_per_second()
	
	# Get the current Date and Time
	var datetime = Time.get_datetime_dict_from_system()
	
	# Format the string
	# %02d ensures leading zeros (e.g., 09 instead of 9)
	var time_string = $map/CanvasModulate.get_full_time_string()
	var date_string = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]
	
	# Update the label text
	$UI/VBoxContainer/Label.text = "FPS: %d | Date: %s | Time: %s" % [fps, date_string, time_string]
	
	# Update the materials UI
	update_material_display()
	
	# Update the game menu tab
	update_game_menu()
	
	# handle any structure prespawning
	if prespawned_structure:
		prespawned_structure.position = get_global_mouse_position().snapped(Vector2(12, 12))# + Vector2(6, 6)
		
# show various game stats
func update_game_menu():
	$UI/TabContainer/Game/HBoxContainer/RichTextLabel.text = dict_to_bbcode_list(count_group_membership(unit_list))
	$UI/TabContainer/Game/HBoxContainer/RichTextLabel2.text = dict_to_bbcode_list(count_group_membership(structure_list))
	$UI/TabContainer/Game/HBoxContainer/RichTextLabel3.text = str(MultiplayerManager.player_name) + '\nFaction: ' + str(MultiplayerManager.local_faction)
	
func update_material_display():
	for mat_name in materials.keys():
		get_node('UI/VBoxContainer/GUIMatDisplay/' + mat_name).text = str(int(materials[mat_name]))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('next_idle_unit'):
		select_next_idle_unit()
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_V:
			spawn_villager.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_W:
			spawn_warrior.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_M:
			spawn_wizard.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_A:
			spawn_archer.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_B:
			spawn_animal.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_H:
			spawn_house.rpc_id(1, get_global_mouse_position())
		if event.pressed and event.keycode == KEY_ESCAPE:
			if prespawned_structure:
				prespawned_structure.queue_free()
				prespawned_structure = null
				CursorManager.reset_cursor()
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if prespawned_structure:
			actually_spawn_structure()

func select_next_idle_unit():
	var shuffled_unit_list = unit_list.duplicate()
	shuffled_unit_list.shuffle()
	for unit in shuffled_unit_list:
		if unit:
			if not unit.autonomous_mode and not unit in $SelectionManager.selected_units:
				$SelectionManager.deselect_all()
				$SelectionManager.handle_single_selection(unit.global_position, false)
				$SelectionManager.center_camera_on_selection()
				break

@rpc('any_peer', 'call_local', 'reliable')
func spawn_villager(spawn_pos: Vector2, unit_lore_data = null):
	if multiplayer.is_server():
		# AKA SERVER CALLING SERVER
		var authority:int
		if multiplayer.get_remote_sender_id() == 0:
			authority = 1
		else:
			authority = multiplayer.get_remote_sender_id() 
		var spawn_data = {
			'type': 'villager', 
			'spawn_pos': spawn_pos, 
			'auth': authority, 
			'faction': MultiplayerManager.get_faction_from_id(authority) if not alt_held else 7,
			'unit_lore_data': unit_lore_data
			}
		# This triggers _on_unit_spawned on BOTH server and all clients
		$entities/units/MultiplayerSpawner.call_deferred("spawn", spawn_data)

@rpc('any_peer', 'call_local', 'reliable')
func spawn_warrior(spawn_pos: Vector2, unit_lore_data = null):
	if multiplayer.is_server():
		# AKA SERVER CALLING SERVER
		var authority:int
		if multiplayer.get_remote_sender_id() == 0:
			authority = 1
		else:
			authority = multiplayer.get_remote_sender_id() 
		var spawn_data = {
			'type': 'warrior', 
			'spawn_pos': spawn_pos, 
			'auth': authority, 
			'faction': MultiplayerManager.get_faction_from_id(authority) if not alt_held else 7,
			'unit_lore_data': unit_lore_data
			}
		# This triggers _on_unit_spawned on BOTH server and all clients
		$entities/units/MultiplayerSpawner.call_deferred("spawn", spawn_data)

@rpc('any_peer', 'call_local', 'reliable')
func spawn_archer(spawn_pos: Vector2, unit_lore_data = null):
	if multiplayer.is_server():
		# AKA SERVER CALLING SERVER
		var authority:int
		if multiplayer.get_remote_sender_id() == 0:
			authority = 1
		else:
			authority = multiplayer.get_remote_sender_id() 
		var spawn_data = {
			'type': 'archer', 
			'spawn_pos': spawn_pos, 
			'auth': authority, 
			'faction': MultiplayerManager.get_faction_from_id(authority) if not alt_held else 7,
			'unit_lore_data': unit_lore_data
			}
		# This triggers _on_unit_spawned on BOTH server and all clients
		$entities/units/MultiplayerSpawner.call_deferred("spawn", spawn_data)

@rpc('any_peer', 'call_local', 'reliable')
func spawn_wizard(spawn_pos: Vector2, unit_lore_data = null):
	if multiplayer.is_server():
		# AKA SERVER CALLING SERVER
		var authority:int
		if multiplayer.get_remote_sender_id() == 0:
			authority = 1
		else:
			authority = multiplayer.get_remote_sender_id() 
		var spawn_data = {
			'type': 'wizard', 
			'spawn_pos': spawn_pos, 
			'auth': authority, 
			'faction': MultiplayerManager.get_faction_from_id(authority) if not alt_held else 7,
			'unit_lore_data': unit_lore_data
			}
		# This triggers _on_unit_spawned on BOTH server and all clients
		$entities/units/MultiplayerSpawner.call_deferred("spawn", spawn_data)

@rpc('any_peer', 'call_local', 'reliable')
func spawn_animal(spawn_pos: Vector2):
	if multiplayer.is_server():
		var spawn_data = {
			'type': 'animal', 
			'spawn_pos': spawn_pos, 
			'auth': 1,
			'faction': -1,
			'unit_lore_data': null
			}
		# This triggers _on_unit_spawned on BOTH server and all clients
		$entities/units/MultiplayerSpawner.call_deferred("spawn", spawn_data)

# generic on unit spawned function for spawner
func _on_unit_spawned(spawning_data: Dictionary) -> Node:
	var type = spawning_data.type 
	var spawn_pos = spawning_data.spawn_pos
	var auth = spawning_data.auth
	var faction = spawning_data.faction
	var unit_lore_data = spawning_data.unit_lore_data
	
	var unit_scene
	match type:
		'villager': 
			unit_scene = preload("res://scenes/entities/units/villager.tscn")
		'wizard': 
			unit_scene = preload("res://scenes/entities/units/wizard.tscn")	
		'warrior': 
			unit_scene = preload("res://scenes/entities/units/warrior.tscn")
		'archer': 
			unit_scene = preload("res://scenes/entities/units/archer.tscn")
		'animal': 
			var animal = preload("res://scenes/entities/npcs/animal.tscn").instantiate()
			# animals will defualt have an authity of 1 (server) and a faction of (-1)
			animal.set_multiplayer_authority(auth)
			animal.prepare(auth, faction, null, "animal")
			animal.position = spawn_pos
			return animal
		#_: pass
	var unit = unit_scene.instantiate()
	unit.set_multiplayer_authority(auth)
	unit.prepare(auth, faction, unit_lore_data, type)
	unit.position = spawn_pos
	if auth == multiplayer.get_unique_id():
		unit_list.append(unit)
		# Connect a signal to remove it when it dies
		unit.tree_exiting.connect(func(): unit_list.erase(unit))
	return unit
		
@rpc('any_peer', 'call_local', 'reliable')	
func spawn_house(spawn_pos: Vector2):
	if multiplayer.is_server():
		# AKA SERVER CALLING SERVER
		var authority:int
		if multiplayer.get_remote_sender_id() == 0:
			authority = 1
		else:
			authority = multiplayer.get_remote_sender_id() 
		var house = preload("res://scenes/entities/structures/generic_structure.tscn").instantiate()
		house.set_multiplayer_authority(authority)
		house.prepare(authority, MultiplayerManager.get_faction_from_id(authority) if not alt_held else 7)
		house.position = spawn_pos
		$entities/structures.add_child(house, true)
		structure_list.append(house)

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
	
	# clear the rich text label detailing party stats
	var party_comp_label = $UI/TabContainer/Selection/HBoxContainer/VBoxContainer/RichTextLabel
	party_comp_label.clear()
	
	# clear the textures in the the grid container
	for child in $UI/TabContainer/Selection/HBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	
	have_a_villager_in_selection = false
	# add them back in, which calculating stats
	for unit in selected_units:
		if unit:
			if unit.lore_data.type == 'villager':
				have_a_villager_in_selection = true
			
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
		
	# update the stats label
	party_comp_label.text = dict_to_bbcode_list(count_group_membership(selected_units))
	
	# update the buttons so they toggle AI for the selections
	var ai_on_button = $UI/TabContainer/Selection/HBoxContainer/VBoxContainer2/Button
	var ai_off_button = $UI/TabContainer/Selection/HBoxContainer/VBoxContainer2/Button2
	
	var turn_ai_off_for_units = func():
		for unit in selected_units:
			if unit:
				unit.set_autonomous_mode(false)
		
	var turn_ai_on_for_units = func():
		for unit in selected_units:
			if unit:
				unit.set_autonomous_mode(true)
			
	# Connect signal to button after clearing prior signals
	for connection in ai_on_button.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	ai_on_button.pressed.connect(turn_ai_on_for_units)
	
	for connection in ai_off_button.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	ai_off_button.pressed.connect(turn_ai_off_for_units)
	
	
	if selected_units.size() == 1:
		update_unit_menu(selected_units[0])
	elif selected_units.size() > 1:
		set_tab_hidden_by_name($UI/TabContainer, 'Selection', false)
		$UI/TabContainer/Selection.show()
	elif selected_units.size() == 0:
		set_tab_hidden_by_name($UI/TabContainer, 'Selection', true)
		set_tab_hidden_by_name($UI/TabContainer, 'Unit', true)
		
func update_unit_menu(unit, swap_to_tab:bool = true):
	# SHOW THE TAB
	set_tab_hidden_by_name($UI/TabContainer, 'Unit', false)
	if swap_to_tab:
		$UI/TabContainer/Unit.show()
	
	# set up some references for easy access later
	var delete_button = $UI/TabContainer/Unit/HBoxContainer/VBoxContainer2/Button4
	var unassign_button = $UI/TabContainer/Unit/HBoxContainer/VBoxContainer2/Button5
	var ai_toggle = $UI/TabContainer/Unit/HBoxContainer/VBoxContainer2/CheckButton
	
	# set the ai toggle_button properly
	if unit.autonomous_mode:
		ai_toggle.button_pressed = true
	else:
		ai_toggle.button_pressed = false
	
	# disable the button if the unit is not assigned to anything
	if not unit.assigned_structure:
		unassign_button.disabled = true
	else:
		unassign_button.disabled = false

	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer/Label.text = unit.lore_data.name
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer/RichTextLabel.text = unit.lore_data.desc
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer3/Label.text = '(' + unit.lore_data.type + ')'
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer3/RichTextLabel.text = dict_to_bbcode_list(unit.lore_data.stats)
	$UI/TabContainer/Unit/HBoxContainer/TextureRect.texture = get_cropped_tile_texture(unit.random_atlas_coords)
	$UI/TabContainer/Unit/HBoxContainer/VBoxContainer2/RichTextLabel.text = 'Assigned to:\n' + str(unit.assigned_structure) 
	
	var toggle_ai_unit = func():
		if unit:
			unit.set_autonomous_mode(not unit.autonomous_mode)
	
	var delete_unit = func():
		if unit:
			if 'on_death' in unit:
				unit.on_death()
				# HIDE THE TAB if unit is deleted
				set_tab_hidden_by_name($UI/TabContainer, 'Unit', true)
	
	var unassign_unit = func():
		if unit:
			unit.unassign_from_structure()
			# update the unit menu
			update_unit_menu(unit, false)
	
	# Connect signal to button after clearing prior signals
	for connection in delete_button.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	delete_button.pressed.connect(delete_unit)
	
	for connection in unassign_button.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	unassign_button.pressed.connect(unassign_unit)
	
	for connection in ai_toggle.get_signal_connection_list("pressed"):
		connection.signal.disconnect(connection.callable)
	ai_toggle.pressed.connect(toggle_ai_unit)
	
func get_cropped_tile_texture(atlas_coords: Vector2i) -> AtlasTexture:
	
	if str(atlas_coords) in already_made_atlas_textures:
		return already_made_atlas_textures[str(atlas_coords)]
	
	var source = preload('res://resources/urizen.tres').get_source(0) as TileSetAtlasSource
	
	if source:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = source.texture
		atlas_tex.region = source.get_tile_texture_region(atlas_coords)
		already_made_atlas_textures[str(atlas_coords)] = atlas_tex
		return atlas_tex
	return null

func set_tab_hidden_by_name(tab_container: TabContainer, tab_name: String, state: bool):
	for i in range(tab_container.get_tab_count()):
		if tab_container.get_tab_title(i) == tab_name:
			tab_container.set_tab_hidden(i, state)
			return


## DEBUG SHIT: TO TEST THE DRAG AND DROP SYSTEM
func _on_button_pressed() -> void:
	if not prespawned_structure:
		# 1. Get the Index (0, 1, 2...)
		var selected_idx = option_button.selected
		# 2. Get the Text (The string shown to the user)
		var selected_text = option_button.get_item_text(selected_idx)
		prespawn_structure(GlobalVars.filter_json_objects(GlobalVars.lore.structures, 'name', selected_text)[0])
	
func prespawn_structure(structure_data: Dictionary = GlobalVars.lore.structures.pick_random(), structure_path: String = 'res://scenes/entities/structures/generic_structure.tscn'):
	var structure = load(structure_path).instantiate()
	structure.prepare(1, 0 if not alt_held else 1, structure_data)
	if structure.has_method('toggle_blue_tint'):
		structure.toggle_blue_tint(true)
	structure.position = get_global_mouse_position()
	# Disable collisions
	structure.collision_layer = 0
	prespawned_structure = structure
	$entities/structures.add_child(structure, true)
	CursorManager.set_cursor(CursorManager.Type.BUILD)

func actually_spawn_structure():
	if prespawned_structure:
		if prespawned_structure.has_method('toggle_blue_tint'):
			prespawned_structure.toggle_blue_tint(false)
		# TODO: actually validate that structure can be placed at that position
		prespawned_structure.position = get_global_mouse_position().snapped(Vector2(12, 12)) #+ Vector2(6, 6)
		# Enable collisions
		prespawned_structure.collision_layer = 1
		prespawned_structure.start_building()
		prespawned_structure.actually_spawned = true
		structure_list.append(prespawned_structure)
		prespawned_structure.structure_destroyed.connect(on_structure_destroyed)
		prespawned_structure = null
		CursorManager.reset_cursor()
		
func on_structure_destroyed(destroyed_structure: Structure):
	# update the build option button and stuff, so requirements are correct now that a structure is deleted
	structure_list.erase(destroyed_structure)
	_on_option_button_item_selected(option_button.get_selected_id())
	

func update_structure_menu(structure: Structure, swap_to_tab:bool = true):
	# SHOW THE TAB
	set_tab_hidden_by_name($UI/TabContainer, 'Structure', false)
	if swap_to_tab:
		$UI/TabContainer/Structure.show()
		
	# display basic structure info
	$UI/TabContainer/Structure/HBoxContainer/VBoxContainer/Label.text = structure.lore_data.name
	$UI/TabContainer/Structure/HBoxContainer/VBoxContainer/RichTextLabel.text = structure.lore_data.desc
	$UI/TabContainer/Structure/HBoxContainer/VBoxContainer3/Label.text = 'Tier ' + str(structure.current_tier)
	
	# update the spawnable units menu
	var spawn_button_container = $UI/TabContainer/Structure/HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer
	for child in spawn_button_container.get_children():
		child.queue_free()
		
	if 'spawnable_units' in structure.lore_data.tiers[str(structure.current_tier)]:
		for unit_name in structure.lore_data.tiers[str(structure.current_tier)].spawnable_units:
			var spawn_button = Button.new()
			spawn_button.text = unit_name
			spawn_button.add_to_group("spawnable_buttons")
			var icon_texture
			if GlobalVars.filter_json_objects(GlobalVars.lore.units, 'name', unit_name)[0].sprite:
				var sprite_atlas_coords = GlobalVars.filter_json_objects(GlobalVars.lore.units, 'name', unit_name)[0].sprite.pick_random()
				icon_texture = get_cropped_tile_texture(str_to_var('Vector2i' + str(sprite_atlas_coords)))
			else:
				icon_texture = preload('res://assets/icons/kenney_game-icons-expansion/Game icons (base)/PNG/White/1x/singleplayer.png')
			spawn_button.icon = icon_texture
			spawn_button.icon_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			spawn_button.vertical_icon_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP
			spawn_button.expand_icon = true
			spawn_button.custom_minimum_size = Vector2(75, 75)
			var unit_spawn_material_reqs = GlobalVars.filter_json_objects(GlobalVars.lore.units, 'name', unit_name)[0].cost
			spawn_button.tooltip_text = str(unit_spawn_material_reqs)
			spawn_button.set_meta('material_reqs', unit_spawn_material_reqs)
			
			# set the initial button state
			if not check_if_enough_materials(unit_spawn_material_reqs):
				spawn_button.disabled = true
			
			# set the button to add to spawn queue when pressed
			var add_unit_to_queue = func():
				if structure.has_node('SpawnUnitsComponent'):
					# only add if enough materials
					if check_if_enough_materials(unit_spawn_material_reqs):
						# subtract the materials and add the unit to the spawn queue
						subtract_materials(unit_spawn_material_reqs)
						structure.get_node('SpawnUnitsComponent').add_new_unit_to_queue(unit_name)

			spawn_button.pressed.connect(add_unit_to_queue)
			
			# finally add the button
			spawn_button_container.add_child(spawn_button)
			
	# display tier upgrade info
	var tier_upgrade_text:String = 'Needs:\n'
	var _next_tier = clampi(structure.current_tier + 1, 1, 3) # there are only 3 tiers 
	var upgrade_cost = structure.lore_data.tiers[str(int(structure.current_tier))].upgrade_cost
	for key in upgrade_cost:
		var mat_type = key
		tier_upgrade_text += mat_type + ' ' + str(int(upgrade_cost[key])) + '\n'
	tier_upgrade_text += 'to upgrade.'
	$UI/TabContainer/Structure/HBoxContainer/VBoxContainer3/RichTextLabel.text = tier_upgrade_text
	
	# display any mats the structure periodically spawns
	var mat_gui = $UI/TabContainer/Structure/HBoxContainer/VBoxContainer/HBoxContainer
	# hide all initially
	for child in mat_gui.get_children():
		child.hide()
	if 'generation' in structure.lore_data.tiers[str(int(structure.current_tier))]:
		var amounts = structure.lore_data.tiers[str(int(structure.current_tier))].generation
		for mat_type in materials.keys():
			if mat_type in amounts:
				mat_gui.get_node(mat_type).show()
				mat_gui.get_node(mat_type + 'texture').show()
				mat_gui.get_node(mat_type).text = '+' + str(int(amounts[mat_type]))
			else: 
				mat_gui.get_node(mat_type).hide()
				mat_gui.get_node(mat_type + 'texture').hide()
	
		# configure delete button
		var delete_button = $UI/TabContainer/Structure/HBoxContainer/VBoxContainer2/Button4
		
		var delete_structure = func():
			if structure:
				if 'on_death' in structure:
					structure.on_death()
					# HIDE THE TAB if structure is deleted
					set_tab_hidden_by_name($UI/TabContainer, 'Structure', true)
		
		# Connect signal to button after clearing prior signals
		for connection in delete_button.get_signal_connection_list("pressed"):
			connection.signal.disconnect(connection.callable)
		delete_button.pressed.connect(delete_structure)
		
## Returns a dictionary where keys are Group Names and values are their frequencies
func count_group_membership(node_list: Array) -> Dictionary:
	var group_counts = {}
	
	for node in node_list:
		# get_groups() returns an Array of Strings
		if node:
			var groups = node.get_groups()
			
			for group_name in groups:
				if group_counts.has(group_name):
					group_counts[group_name] += 1
				else:
					group_counts[group_name] = 1
				
	return group_counts

func dict_to_bbcode_list(data: Dictionary) -> String:
	var bbcode = ""
	
	for key in data.keys():
		var value = data[key]
		bbcode += str(key) + ': ' + str(value) + "\n"
	
	return bbcode

func _on_option_button_item_selected(index: int) -> void:
	
	# get the structure requirements
	var selected_structure_name = option_button.get_item_text(index)
	var selected_structure = GlobalVars.filter_json_objects(GlobalVars.lore.structures, 'name', selected_structure_name)[0]
	var required_structure_names = selected_structure.required_structures
	# Create a list of the existing structure names
	var existing_structure_names = []
	for structure in structure_list:
		if structure:
			existing_structure_names.append(structure.lore_data.name)
	print('Required: ' + str(required_structure_names))
	print('Have: ' + str(existing_structure_names))
	
	# show the structure requirements
	var label = $UI/TabContainer/Build/HBoxContainer/RichTextLabel
	var label_string = 'Structure Requirements:\n'
	for thing in required_structure_names:
		label_string += thing
		if thing in existing_structure_names:
			label_string += ' [img]res://assets/icons/kenney_game-icons-expansion/Game icons (base)/PNG/White/1x/checkmark.png[/img]'
		else:
			label_string += ' [img]res://assets/icons/kenney_game-icons-expansion/Game icons (base)/PNG/White/1x/cross.png[/img]'

		label_string += '\n'
	
	label.text = label_string

	# TODO: get the material requirements
	
	# TODO: show the material requirements

	# Finally enable or disable the button
	if GlobalVars.array_contains_all(required_structure_names, existing_structure_names):
		$UI/TabContainer/Build/HBoxContainer/VBoxContainer/Button.disabled = false
	else:
		$UI/TabContainer/Build/HBoxContainer/VBoxContainer/Button.disabled = true

@rpc("any_peer","call_local","reliable")
func check_if_enough_materials(material_req:Dictionary):
	for key in material_req.keys():
		if materials[key] < material_req[key]:
			return false
	return true

@rpc("any_peer","call_local","reliable")
func subtract_materials(material_req:Dictionary):
	for key in material_req.keys():
		materials[key] -= material_req[key]
		if materials[key] < 0:
			materials[key] = 0
	materials_changed.emit()
	
# update any spawnbale buttons that are there 
func update_spawnable_buttons():
	for button in get_tree().get_nodes_in_group("spawnable_buttons"):
		if button:
			var material_reqs = button.get_meta('material_reqs')
			if check_if_enough_materials(material_reqs):
				button.disabled = false
			else:
				button.disabled = true

func _on_lore_button_pressed() -> void:
	var scene = preload('res://scenes/gui_components/popup_window.tscn').instantiate()
	# TODO: can modify stuff here or just go with defaults
	$UI.add_child(scene)

func _on_controls_button_pressed() -> void:
	var scene = preload('res://scenes/gui_components/popup_window.tscn').instantiate()
	scene.window_title = 'Controls'
	scene.contents_bb_code = 'Info about controls here.'
	$UI.add_child(scene)

func _on_units_button_pressed() -> void:
	var scene = preload('res://scenes/gui_components/popup_window.tscn').instantiate()
	scene.window_title = 'Units'
	scene.contents_bb_code = JSON.stringify(GlobalVars.lore.units)
	$UI.add_child(scene)

func _on_structures_button_pressed() -> void:
	var scene = preload('res://scenes/gui_components/popup_window.tscn').instantiate()
	scene.window_title = 'Structures'
	#scene.contents_bb_code = "This is a list of all the structures you can build."
	scene.contents_json = GlobalVars.lore.structures
	scene.setup_tree_view()
	$UI.add_child(scene)

func _on_beastiary_button_pressed() -> void:
	var scene = preload('res://scenes/gui_components/popup_window.tscn').instantiate()
	scene.window_title = 'Beastiary'
	scene.contents_bb_code = JSON.stringify(GlobalVars.lore.animals)
	$UI.add_child(scene)
