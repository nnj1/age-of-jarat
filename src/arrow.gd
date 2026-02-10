extends Node2D

class_name Projectile

@export var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 0.0
var attacker: CharacterBody2D = null
var attackers_allies = []
var poison_status: bool

func prepare(given_attacker: CharacterBody2D, given_poison = false):
	attacker = given_attacker
	attackers_allies = attacker.allies.duplicate()
	poison_status = given_poison
	
func _ready() -> void:
	if get_node_or_null('PoisonGPUParticles2D'):
		if poison_status:
			$PoisonGPUParticles2D.visible = true
			$PoisonGPUParticles2D.emitting = true
		else:
			$PoisonGPUParticles2D.visible = false
			$PoisonGPUParticles2D.emitting = false
	
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server(): return
	# Move the arrow in the set direction
	global_position += direction * speed * delta
	
	# Optional: Remove arrow if it flies too far off screen (optimization)
	# You could also use a VisibleOnScreenNotifier2D for this
	if global_position.length() > 5000: 
		queue_free()

func launch(target_direction: Vector2, incoming_damage: float) -> void:
	direction = target_direction
	damage = incoming_damage
	
	# Rotate the arrow to face the direction of travel
	# Vector2.angle() returns the angle in radians
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if body != attacker:
		# FRIENDLY FIRE CHECK, TODO: MAKE THIS TOGGLEABLE
		if not (body.faction in attackers_allies):
			# Look for the HealthComponent specifically
			# Replace "HealthComponent" with the actual name of the node in your scene tree
			var health = body.get_node_or_null("HealthComponent")
			
			if health and health.has_method("take_damage"):
				health.take_damage(damage)
				
			queue_free() # Destroy arrow after hitting something
