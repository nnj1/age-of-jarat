extends Node

## Configuration
@export_group("UI Element Sounds")
@export var click_sound: AudioStream = preload("res://assets/sfx/Fantasy UI SFX/Fantasy UI SFX/Fantasy/Fantasy_UI (1).wav")
@export var hover_sound: AudioStream = preload("res://assets/sfx/Fantasy UI SFX/Fantasy UI SFX/Fantasy/Fantasy_UI (3).wav")

@export_group("Global Input Sounds")
@export var generic_click_sound: AudioStream = preload('res://assets/sfx/UI Soundpack/UI Soundpack/MP3/African1.mp3')
@export var right_click_sound: AudioStream = preload('res://assets/sfx/UI Soundpack/UI Soundpack/MP3/African1.mp3')
@export var escape_key_sound: AudioStream = preload("res://assets/sfx/Fantasy UI SFX/Fantasy UI SFX/Fantasy/Fantasy_UI (2).wav")
@export var tilde_key_sound: AudioStream = preload("res://assets/sfx/Fantasy UI SFX/Fantasy UI SFX/Fantasy/Fantasy_UI (17).wav")
@export var tab_key_sound: AudioStream = preload("res://assets/sfx/UI Soundpack/UI Soundpack/MP3/Wood Block1.mp3")

@export_group("Settings")
@export var pool_size: int = 8
@export var bus_name: String = "UI"
@export var min_pitch: float = 0.95
@export var max_pitch: float = 1.05

var _pool: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0

func _ready() -> void:
	for i in range(pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = bus_name
		add_child(player)
		_pool.append(player)
	
	get_tree().node_added.connect(_on_node_added)
	_scan_node_recursive(get_tree().root)

## Detects Global Mouse and Key presses
func _input(event: InputEvent) -> void:
	# 1. Handle Mouse Clicks
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Only play generic sound if we aren't clicking a UI button
			# We use a tiny delay or check 'get_viewport().gui_get_focus_owner()'
			# but the simplest way is checking if the UI handled it first:
			if not get_viewport().gui_is_dragging(): 
				# This is a broad catch; if no UI button consumed this, it plays.
				# Note: Buttons usually consume 'pressed', so this works best in _unhandled_input
				# but for generic clicks, _input is fine.
				play_sfx(generic_click_sound)
				
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			play_sfx(right_click_sound)

	# 2. Handle Key Presses
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				play_sfx(escape_key_sound)
			KEY_QUOTELEFT: # This is the Tilde (~) key
				play_sfx(tilde_key_sound)
			KEY_TAB: # This is the Tilde (~) key
				play_sfx(tab_key_sound)

## Public play function
func play_sfx(stream: AudioStream):
	if not stream: return
	var player = _pool[_next_player_index]
	player.stream = stream
	player.pitch_scale = randf_range(min_pitch, max_pitch)
	player.play()
	_next_player_index = (_next_player_index + 1) % pool_size

## --- Rest of your existing node-added logic ---

func _on_node_added(node: Node) -> void:
	if node is Control: _setup_ui_node(node)

func _setup_ui_node(node: Control) -> void:
	if node.has_meta("skip_ui_sound") or node.is_in_group("no_ui_sound"): return
	if node is BaseButton:
		node.pressed.connect(func(): play_sfx(click_sound))
		node.mouse_entered.connect(func(): play_sfx(hover_sound))

func _scan_node_recursive(node: Node) -> void:
	_on_node_added(node)
	for child in node.get_children(): _scan_node_recursive(child)
