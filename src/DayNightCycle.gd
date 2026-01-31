extends CanvasModulate

## The gradient defining colors for the 24-hour cycle
@export var cycle_gradient: Gradient
## How many real-world minutes a full game day lasts
@export var day_duration_minutes: float = 1.0

## The variable that will be synchronized across the network.
## Using a setter (set) ensures the color updates the moment the server sends a new value.
@export var sync_time: float = 0.5:
	set(value):
		sync_time = value
		_update_visuals()

var time_speed: float = 0.0

func _ready():
	# Calculate how much 0.0-1.0 progress happens per second
	time_speed = 1.0 / (day_duration_minutes * 60.0)
	
	# Initial visual update
	_update_visuals()
	
func get_full_time_string() -> String:
	# Total seconds in a full day
	var total_seconds_in_day = sync_time * 86400.0
	
	# Breakdown into units
	var hours = int(total_seconds_in_day / 3600.0)
	var minutes = int(fmod(total_seconds_in_day / 60.0, 60.0))
	var seconds = int(fmod(total_seconds_in_day, 60.0))
	
	# Returns formatted as 00:00:00
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _process(delta: float):
	# Only the Server (Authority) calculates the passage of time
	if multiplayer.is_server():
		sync_time += delta * time_speed
		
		# Reset cycle at the end of the day
		if sync_time >= 1.0:
			sync_time = 0.0

func _update_visuals():
	# This runs on both Server and Clients whenever sync_time is updated
	if cycle_gradient:
		self.color = cycle_gradient.sample(sync_time)

## Helper function to get a clock string for UI
func get_time_string() -> String:
	var total_hours = sync_time * 24.0
	var hours = int(total_hours)
	var minutes = int((total_hours - hours) * 60.0)
	return "%02d:%02d" % [hours, minutes]
