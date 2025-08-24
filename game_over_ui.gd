extends CanvasLayer

@onready var message_label = $Overlay/Container/MessageLabel
@onready var restart_button = $Overlay/Container/RestartButton

func _ready():
	visible = false
	restart_button.pressed.connect(_on_restart_button_pressed)
	GameManager.game_over.connect(_on_game_over)

func _on_game_over(reason: String):
	message_label.text = reason
	visible = true
	restart_button.grab_focus()

func _on_restart_button_pressed():
	GameManager.reset_game()
	get_tree().reload_current_scene()
