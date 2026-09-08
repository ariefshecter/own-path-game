extends Control

@onready var name_input: LineEdit = $VBoxContainer/FormBox/NameInput
@onready var start_btn: Button = $VBoxContainer/StartButton
@onready var continue_btn: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	name_input.text = GameState.player_name
	start_btn.pressed.connect(_on_start_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	
	if GameState.has_saved_profile():
		continue_btn.visible = true
		continue_btn.text = "LANJUTKAN PERJALANAN (%s - Ch %d.%d)" % [
			GameState.player_name, 
			GameState.current_chapter, 
			GameState.current_mini_chapter
		]
		start_btn.text = "MULAI DARI AWAL (PROFIL BARU)"
	else:
		continue_btn.visible = false
		start_btn.text = "MULAI JALAN SENDIRI"

func _on_start_pressed() -> void:
	var entered = name_input.text.strip_edges()
	if entered != "":
		GameState.player_name = entered
	GameState.hard_reset_entire_game()
	GameState.player_name = entered if entered != "" else "Rian"
	GameState.save_game()
	get_tree().change_scene_to_file("res://scenes/Prologue.tscn")

func _on_continue_pressed() -> void:
	# Lanjutkan ke Kamar Kos (Hub)
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")
