extends Control

@onready var chat_display: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var chat_input: LineEdit = $PanelContainer/VBoxContainer/LineEdit

func _ready():
	# Ensure the input starts unfocused
	chat_input.release_focus()
	
	# Optional: styling the chat display to auto-scroll
	chat_display.scroll_following = true
	
	chat_input.text_submitted.connect(_on_text_submitted)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if not chat_input.has_focus():
			chat_input.grab_focus()
			# Consume the event so it doesn't trigger other things
			get_viewport().set_input_as_handled()

func _on_text_submitted(new_text: String):
	if new_text != "":
		# 1. Send the text to the chat
		rpc('update_chat_display', MultiplayerManager.player_name + ': ' + new_text)
	# 2. Clear the input field
	chat_input.clear()
	# 3. Release focus so the player can move/play again
	chat_input.release_focus()

@rpc("any_peer", "call_local", "reliable")
func update_chat_display(message: String):
	chat_display.append_text("\n" + message)
