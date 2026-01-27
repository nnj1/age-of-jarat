extends Node2D

enum State { IDLE, WANDER, AGGRO, FRIGHTENED, GATHERING, RETURNING }
enum Stance { PASSIVE, DEFENSIVE, AGGRESSIVE }

var current_state: State = State.IDLE

@export_group("Behavior Toggles")
@export var enabled: bool = true
@export var current_stance: Stance = Stance.DEFENSIVE
@export var can_gather: bool = true 
@export var disable_in_fog: bool = true # Toggle for performance

@export_group("Settings")
@export var think_interval: float = 0.6
@export var leash_radius: float = 150.0
@export var idle_time_range: Vector2 = Vector2(1.5, 4.0)
@export var collection_time: float = 3.0
@export var DEBUG_MODE: bool = false

# Nodes (Assumes these exist as children in your Scene)
@onready var state_timer: Timer = $StateTimer
@onready var think_timer: Timer = $ThinkTimer
@onready var sensor_area: Area2D = $SensorArea
@onready var state_label: Label = $StateLabel

var parent_unit: Unit
var home_position: Vector2
var threat: Node2D = null
var target_resource: Node2D = null
var nearby_resources: Array[Node2D] = []
var current_dropoff_target: Vector2 = Vector2.ZERO

# --- Fog Logic ---
var is_in_fog: bool = false : set = set_is_in_fog

func set_is_in_fog(value: bool):
	if is_in_fog == value: return
	is_in_fog = value
	
	if is_in_fog and disable_in_fog:
		think_timer.stop()
		state_timer.paused = true
		if state_label: state_label.visible = false
	else:
		if enabled:
			think_timer.start()
			state_timer.paused = false
			if state_label: state_label.visible = true
			_update_debug_label()

func _pause_brain():
	think_timer.stop()
	state_timer.paused = true
	if state_label: state_label.visible = false
	# Clean up current movement if they "disappear" for the player
	# parent_unit.is_moving = false

func _resume_brain():
	if enabled:
		think_timer.start()
		state_timer.paused = false
		if state_label: state_label.visible = true
		_update_debug_label()

# --- Core Setup ---

func _ready():
	if not DEBUG_MODE:
		state_label = null
		
	parent_unit = get_parent() as Unit
	home_position = parent_unit.global_position
	
	if not state_timer.timeout.is_connected(_on_state_timer_timeout):
		state_timer.timeout.connect(_on_state_timer_timeout)
	
	think_timer.wait_time = think_interval
	if not think_timer.timeout.is_connected(_on_think_tick):
		think_timer.timeout.connect(_on_think_tick)
	
	sensor_area.body_entered.connect(_on_body_entered)
	sensor_area.body_exited.connect(_on_body_exited)
	
	if enabled and not (is_in_fog and disable_in_fog):
		think_timer.start()
		_change_state(State.IDLE)
	else:
		set_enabled(false)

func set_enabled(value: bool):
	enabled = value
	if not value:
		state_timer.stop()
		think_timer.stop()
		if state_label: state_label.text = "MANUAL"
	else:
		if not (is_in_fog and disable_in_fog):
			think_timer.start()
		_change_state(State.IDLE)

# --- Brain Logic ---

func _on_think_tick():
	# Early exit if hidden or disabled
	if not enabled or (is_in_fog and disable_in_fog): return
	if not parent_unit.is_multiplayer_authority(): return
	
	match current_state:
		State.FRIGHTENED:
			if is_instance_valid(threat):
				var flee_dir = threat.global_position.direction_to(parent_unit.global_position)
				var flee_point = parent_unit.global_position + (flee_dir * 100.0)
				parent_unit.set_move_target(flee_point)
			else:
				_change_state(State.RETURNING)

		State.AGGRO:
			if is_instance_valid(threat):
				parent_unit.set_move_target(threat.global_position)
				if current_stance == Stance.DEFENSIVE:
					var dist_sq = parent_unit.global_position.distance_squared_to(home_position)
					if dist_sq > pow(leash_radius * 2.5, 2):
						threat = null
						_change_state(State.RETURNING)
			else:
				_change_state(State.RETURNING)

		State.GATHERING:
			if is_instance_valid(target_resource):
				var dist_sq = parent_unit.global_position.distance_squared_to(target_resource.global_position)
				if dist_sq < 400.0:
					if state_timer.is_stopped(): 
						_start_collecting()
			else:
				_change_state(State.RETURNING)

		State.RETURNING:
			var dest = current_dropoff_target if current_dropoff_target != Vector2.ZERO else home_position
			parent_unit.set_move_target(dest)
			if parent_unit.global_position.distance_squared_to(dest) < 400.0:
				current_dropoff_target = Vector2.ZERO
				_change_state(State.IDLE)

# --- Logic & Sensors ---

func _change_state(new_state: State):
	if current_state == State.FRIGHTENED: 
		parent_unit.speed /= 1.5 
	
	current_state = new_state
	_update_debug_label()
	
	match new_state:
		State.IDLE:
			state_timer.start(randf_range(idle_time_range.x, idle_time_range.y))
		State.FRIGHTENED:
			parent_unit.speed *= 1.5
			state_timer.start(3.5)
		State.RETURNING:
			current_dropoff_target = _find_nearest_dropoff()

func _on_state_timer_timeout():
	if is_in_fog and disable_in_fog: return # Don't trigger transitions in fog
	
	match current_state:
		State.IDLE:
			if can_gather:
				target_resource = _find_best_resource()
				if target_resource:
					parent_unit.set_move_target(target_resource.global_position)
					_change_state(State.GATHERING)
					return
			_do_wander()
		State.GATHERING, State.FRIGHTENED:
			_change_state(State.RETURNING)

func _on_body_entered(body):
	if body == parent_unit: return
	if body.is_in_group("Resources"):
		nearby_resources.append(body)
	elif ((body is Unit) or (body is Structure)) and not body.faction in parent_unit.allies and not body.faction == -1:
		threat = body
		_evaluate_threat_by_stance()

func _evaluate_threat_by_stance():
	# If in fog, we don't react to threats automatically
	if is_in_fog and disable_in_fog: return
	
	match current_stance:
		Stance.PASSIVE: _change_state(State.FRIGHTENED)
		Stance.DEFENSIVE, Stance.AGGRESSIVE: _change_state(State.AGGRO)

func _on_body_exited(body):
	if body in nearby_resources: nearby_resources.erase(body)
	if body == threat:
		if current_stance != Stance.AGGRESSIVE:
			threat = null
			if current_state == State.AGGRO: _change_state(State.RETURNING)

# --- Utility Functions ---

func _find_nearest_dropoff() -> Vector2:
	var dropoffs = get_tree().get_nodes_in_group("Dropoffs")
	if dropoffs.is_empty(): return home_position
	var closest_node = null
	var min_dist = 1e10
	for d in dropoffs:
		var d_sq = parent_unit.global_position.distance_squared_to(d.global_position)
		if d_sq < min_dist:
			min_dist = d_sq
			closest_node = d
	return closest_node.global_position

func _find_best_resource():
	var best = null
	var d_min = 1e10
	for res in nearby_resources:
		if is_instance_valid(res):
			var d = parent_unit.global_position.distance_squared_to(res.global_position)
			if d < d_min: 
				d_min = d
				best = res
	return best

func _start_collecting():
	parent_unit.is_moving = false
	parent_unit.stop_jumping()
	state_timer.start(collection_time)

func _do_wander():
	var offset = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * randf_range(30, leash_radius)
	parent_unit.set_move_target(home_position + offset)

func _update_debug_label():
	if not state_label or not state_label.visible: return
	state_label.text = "[%s]\n%s" % [Stance.keys()[current_stance], State.keys()[current_state]]
	match current_state:
		State.AGGRO: state_label.modulate = Color.RED
		State.FRIGHTENED: state_label.modulate = Color.ORANGE
		State.GATHERING: state_label.modulate = Color.CYAN
		State.RETURNING: state_label.modulate = Color.GOLD
		_: state_label.modulate = Color.WHITE
