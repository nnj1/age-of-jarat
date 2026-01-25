extends Node2D
@onready var main_game_node = get_tree().get_root().get_node('Game')

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func set_sword_texture(given_texture: Texture2D):
	$Sprite2D.texture = given_texture
