extends Control

@onready var reset_btn: Button = $VBoxContainer/ResetButton

func _ready() -> void:
	# Lakukan hard reset progres di state
	GameState.hard_reset_entire_game()
	reset_btn.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")
