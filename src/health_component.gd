extends Node2D
class_name HealthComponent

signal died
signal just_took_damage

@export var max_health: float = 100.0
var current_health: float = max_health

# TODO: incorporate this somehow
@export var armor: int = 0

# Reference the Sprite/Polygon instead of a ProgressBar
@onready var foreground = $BarForeground 

func _ready():
	current_health = max_health
	visible = false # Keep hidden by default
	
	_update_bar()

func take_damage(amount: float):
	if amount > 0:
		set_bar_visibility(true)
		just_took_damage.emit()
		current_health = clamp(current_health - amount, 0, max_health)
		_update_bar()
		if current_health <= 0:
			died.emit()

func _update_bar():
	# We only change the scale.x, which is extremely cheap for the GPU
	var health_pct = current_health / max_health
	foreground.scale.x = health_pct
	
	# Color shifting without theme overhead
	if health_pct < 0.3:
		foreground.modulate = Color.RED
	elif health_pct < 0.6:
		foreground.modulate = Color.YELLOW
	else:
		foreground.modulate = Color.GREEN

func set_bar_visibility(is_selected: bool = false):
	# Only show if selected OR if they are currently injured
	visible = is_selected or (current_health < max_health)
