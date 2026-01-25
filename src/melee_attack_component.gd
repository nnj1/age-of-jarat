extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

var sword_atlas_coords_corners = [
	Vector2i(26,6),
	Vector2i(41,6)
]

var rapier_atlas_coords_corners = [
	Vector2i(26,8),
	Vector2i(37,8)
]

var axe_atlas_coords_corners = [
	Vector2i(26,9),
	Vector2i(39,9)
]

@export_group("Settings")
@export var damage: float = 15.0
@export var attack_speed: float = 1.2
@export var attack_offset: float = 8.0
@export var knockback_force: float = 50.0 
@export var weapon_scene: PackedScene = preload('res://scenes/entities/objects/sword.tscn')
var weapon_texture

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

var targets_in_range: Array[CharacterBody2D] = []
var current_target: CharacterBody2D = null
var active_weapon: Node2D = null # Track the current weapon instance

signal just_melee_attacked

func _ready() -> void:
	
	# set the weapon texture
	var random_sword_coord: Vector2i = GlobalVars.get_vectors_in_range(sword_atlas_coords_corners[0], sword_atlas_coords_corners[1]).pick_random()
	# set a random sword texture
	weapon_texture = main_game_node.get_cropped_tile_texture(random_sword_coord)
	
	attack_timer.wait_time = 1.0 / attack_speed
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	

func _process(_delta: float) -> void:
	_update_target()
	
	if current_target:
		_handle_weapon_instance() # Ensure weapon exists and follows target
		if attack_timer.is_stopped():
			attack()
	else:
		_despawn_weapon() # Remove weapon when no targets are around

func _update_target() -> void:
	targets_in_range = targets_in_range.filter(func(body): return is_instance_valid(body))
	
	if targets_in_range.is_empty():
		current_target = null
		return
	
	current_target = targets_in_range.reduce(func(closest, current):
		var dist_to_closest = global_position.distance_to(closest.global_position)
		var dist_to_current = global_position.distance_to(current.global_position)
		return current if dist_to_current < dist_to_closest else closest
	)

## Manages spawning and positioning the persistent weapon
func _handle_weapon_instance() -> void:
	if not weapon_scene: return
	
	# Spawn if it doesn't exist
	if not is_instance_valid(active_weapon):
		active_weapon = weapon_scene.instantiate()
		active_weapon.set_sword_texture(weapon_texture)
		add_child(active_weapon)
	
	# Update position and rotation to track current_target every frame
	var direction = (current_target.global_position - global_position).normalized()
	active_weapon.rotation = direction.angle()
	active_weapon.position = direction * attack_offset

## Removes the weapon when no targets are in range
func _despawn_weapon() -> void:
	if is_instance_valid(active_weapon):
		active_weapon.queue_free()
		active_weapon = null

func attack() -> void:
	if not current_target:
		return
		
	# Trigger the swing animation on the persistent weapon
	# This assumes your sword scene has an AnimationPlayer named 'AnimationPlayer'
	if active_weapon and active_weapon.has_node("AnimationPlayer"):
		active_weapon.get_node("AnimationPlayer").play("thrust")
	
	# Apply Damage & Knockback logic
	var direction = (current_target.global_position - global_position).normalized()
	
	# Look for the HealthComponent specifically
	# Replace "HealthComponent" with the actual name of the node in your scene tree
	var health = current_target.get_node_or_null("HealthComponent")
	
	if health and health.has_method("take_damage"):
		health.take_damage(damage)
	
	if current_target.has_method("apply_knockback"):
		current_target.apply_knockback(direction * knockback_force)
		
	just_melee_attacked.emit()
	attack_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self.get_parent():
		targets_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	targets_in_range.erase(body)
