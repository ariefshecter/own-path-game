extends Control

@onready var name_input: LineEdit = $VBoxContainer/FormBox/NameInput
@onready var start_btn: Button = $VBoxContainer/StartButton

func _ready() -> void:
	name_input.text = GameState.player_name
	start_btn.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	var entered = name_input.text.strip_edges()
	if entered != "":
		GameState.player_name = entered
	print("Nama Karakter Ditetapkan: ", GameState.player_name)
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")
