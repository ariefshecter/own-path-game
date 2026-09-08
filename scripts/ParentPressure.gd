extends Control

@onready var quote_label: Label = $VBoxContainer/QuoteBox/MarginContainer/HBoxContainer/QuoteLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/QuoteBox/MarginContainer/HBoxContainer/PortraitRect
@onready var try_again_btn: Button = $VBoxContainer/ActionBox/TryAgainButton
@onready var surrender_btn: Button = $VBoxContainer/ActionBox/SurrenderButton

const SPRITE_MOTHER = preload("res://assets/sprites/mother.png")

func _ready() -> void:
	portrait_rect.texture = SPRITE_MOTHER
	try_again_btn.pressed.connect(_on_try_again)
	surrender_btn.pressed.connect(_on_surrender)
	
	var quotes = [
		"\"Tuh kan %s, apa kata Mama! Di luar sana keras, nasibmu kayak mie remuk. Pulanglah, ada pendaftaran CPNS bulan depan!\"" % GameState.player_name,
		"\"%s, Papa sudah bilang, jangan kebanyakan idealis. Anak temen Papa nurut aja sekarang udah bisa kredit mobil lho!\"" % GameState.player_name,
		"\"Kamu di sana makan apa sih %s? Pasti cuma mie campur promag kan? Pulang sekarang, jangan bikin pusing kepala orang tua!\"" % GameState.player_name,
		"\"Mama baru kirim broadcast doa tobat di WA. Tolong dibaca ya le, jangan sampai karma bikin kamu makin sengsara.\""
	]
	quote_label.text = quotes[randi() % quotes.size()]

func _on_try_again() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")

func _on_surrender() -> void:
	get_tree().change_scene_to_file("res://scenes/BadEnding.tscn")
