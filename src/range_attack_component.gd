extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

@export_group("Settings")
@export var damage: float = 10.0
@export var attack_speed: float = 1.0 # Attacks per second
@export var projectile_scene: PackedScene = preload('res://scenes/entities/objects/arrow.tscn') # Reference to your Bullet/Arrow
@export var detection_range: float = 100.0 # how big the detetion area is

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

@export var poison_status: bool = false

var targets_in_range = [] # Will have both CharacterBody2Ds and StaticBody2Ds in it
var current_target = null # could be characterbody2d or staticbody2d

signal just_range_attacked

func _ready() -> void:
	if not is_multiplayer_authority(): return
	poison_status = str(get_parent().lore_data.name) in ['Poison Saboteur']
	
	$DetectionArea/CollisionShape2D.shape.radius = detection_range
	
	attack_timer.wait_time = 1.0 / attack_speed
	# Connect signals to track targets entering/exiting range
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	_update_target()
	
	if current_target and attack_timer.is_stopped():
		attack()

func _update_target() -> void:
	# Filter out any targets that might have been freed/killed
	targets_in_range = targets_in_range.filter(func(body): return is_instance_valid(body))
	
	if targets_in_range.is_empty():
		current_target = null
		return
	
	# Logic: Target the closest enemy
	current_target = targets_in_range.reduce(func(closest, current):
		var dist_to_closest = global_position.distance_to(closest.global_position)
		var dist_to_current = global_position.distance_to(current.global_position)
		return current if dist_to_current < dist_to_closest else closest
	)

func attack() -> void:
	if not projectile_scene or not current_target:
		return
		
	# Spawn the projectile
	#TODO: SHOULD REQUEST SERVER FOR PROJECTILE HERE ACTUALLY
	rpc('request_projectile', self.get_parent().get_path(), current_target.get_path(), poison_status)
	
	just_range_attacked.emit()
	
	attack_timer.start()
	
@rpc("any_peer", "call_local", "reliable")
func request_projectile(unit_node_path: NodePath, target_node_path: NodePath, given_poison_status: bool):
	if not multiplayer.is_server(): return 
	var projectile = projectile_scene.instantiate()
		
	projectile.prepare(get_node(unit_node_path), given_poison_status)
	
	# give it a unique name
	projectile.name = str(multiplayer.get_unique_id()) + "_" + str(Time.get_ticks_msec())
	
	main_game_node.get_node('entities/objects').add_child(projectile, true) # Or add to a specific projectiles folder
	
	# Set projectile position and direction
	projectile.global_position = global_position
	var target = get_node(target_node_path)
	var direction = (target.global_position - global_position).normalized()
	
	# Check if your projectile has a 'setup' or 'launch' method
	if projectile.has_method("launch"):
		projectile.launch(direction, damage)

func _on_body_entered(body: Node2D) -> void:
	if ((body is CharacterBody2D) or (body is StaticBody2D)): # only attacks units and structures
		if body != self.get_parent(): # don't attack self
			if not (body.faction in self.get_parent().allies): # don't attack allies
				# also make sure they aren't in a FOW if they have a wander component
				if body.has_node('WanderComponent'):
					if body.get_node('WanderComponent').is_in_fog:
							return
				targets_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	targets_in_range.erase(body)
