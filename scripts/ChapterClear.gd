extends Control

@onready var chapter_title: Label = $VBoxContainer/ChapterTitle
@onready var desc_label: Label = $VBoxContainer/DescLabel
@onready var next_btn: Button = $VBoxContainer/NextButton

func _ready() -> void:
	chapter_title.text = "CHAPTER 1 SELESAI!"
	desc_label.text = "Selamat %s. Kamu berhasil melewati bayangan rumah dan membuktikan bahwa langkah pertamamu nyata.\n\nKamu tidak lagi gemetar saat mengingat rumah. Dan di tengah hiruk pikuk kota, seseorang tersenyum menyambutmu dengan segelas kopi hangat.\n\nNamun hidup mandiri baru saja dimulai..." % GameState.player_name
	next_btn.pressed.connect(_on_next_pressed)

func _on_next_pressed() -> void:
	# Beralih ke Chapter 2 Bagian 1
	GameState.current_chapter = 2
	GameState.current_mini_chapter = 1
	GameState.current_floor = 1
	GameState.map_floors.clear()
	GameState.current_node_id = ""
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")
