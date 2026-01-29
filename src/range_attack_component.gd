extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

@export_group("Settings")
@export var damage: float = 10.0
@export var attack_speed: float = 1.0 # Attacks per second
@export var projectile_scene: PackedScene = preload('res://scenes/entities/objects/arrow.tscn') # Reference to your Bullet/Arrow
@export var detection_range: float = 100.0 # how big the detetion area is

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

var targets_in_range = [] # Will have both CharacterBody2Ds and StaticBody2Ds in it
var current_target = null # could be characterbody2d or staticbody2d

signal just_range_attacked

func _ready() -> void:
	
	$DetectionArea/CollisionShape2D.shape.radius = detection_range
	
	attack_timer.wait_time = 1.0 / attack_speed
	# Connect signals to track targets entering/exiting range
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
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
	var projectile = projectile_scene.instantiate()
	# see if you need to add poison
	var poison_status = false
	if get_parent().lore_data.name in ['Poison Saboteur']:
		poison_status = true
		
	projectile.prepare(self.get_parent(), poison_status)
	main_game_node.get_node('entities/objects').add_child(projectile, true) # Or add to a specific projectiles folder
	
	# Set projectile position and direction
	projectile.global_position = global_position
	var direction = (current_target.global_position - global_position).normalized()
	
	# Check if your projectile has a 'setup' or 'launch' method
	if projectile.has_method("launch"):
		projectile.launch(direction, damage)
		
	just_range_attacked.emit()
	
	attack_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if ((body is CharacterBody2D) or (body is StaticBody2D)) and body != self.get_parent() and not (body.faction in self.get_parent().allies):
		# TODO: check if the person is a enemy
		targets_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	targets_in_range.erase(body)
