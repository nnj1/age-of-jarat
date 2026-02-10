extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var overlay: ColorRect = $ColorRect
@onready var tip_label: Label = $TipLabel # Ensure this matches your node name

var tips = [
	"Villagers need houses to stay happy and productive.",
	"Deep water is dangerous! Build your village on solid rock.",
	"Mining gold is the fastest way to upgrade your tools.",
	"Forests will regrow slowly over time if you leave some trees standing.",
	"Roads allow your units to move 20% faster!",
	"Fog of War hides dangerous creatures. Explore with caution."
]

func _ready():
	overlay.modulate.a = 0
	tip_label.text = "" # Clear text on start
	hide()

func show_random_tip():
	tip_label.text = tips[randi() % tips.size()]

## Phase 1: Fade and Load
func transition_to(path: String):
	show_random_tip() # Pick a tip before showing the screen
	show()
	
	# Using your working logic (Out to cover, In to reveal)
	anim_player.play("fade_out")
	await anim_player.animation_finished
	
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var progress = []
		ResourceLoader.load_threaded_get_status(path, progress)
		update_bar(progress[0] * 10)
		await get_tree().process_frame
	
	var new_scene_resource = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(new_scene_resource)

func update_bar(value: float):
	progress_bar.value = value

## Phase 2: Fade out
func finish_transition():
	update_bar(100)
	anim_player.play("fade_in")
	await anim_player.animation_finished
	tip_label.text = "" # Clear it for next time
	hide()
