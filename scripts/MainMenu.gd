extends Control

@onready var continue_btn: Button = $VBoxContainer/MenuButtons/ContinueButton
@onready var new_game_btn: Button = $VBoxContainer/MenuButtons/NewGameButton
@onready var settings_btn: Button = $VBoxContainer/MenuButtons/SettingsButton
@onready var credits_btn: Button = $VBoxContainer/MenuButtons/CreditsButton

@onready var settings_modal: PanelContainer = $SettingsModal
@onready var bgm_slider: HSlider = $SettingsModal/MarginContainer/VBoxContainer/BGMControl/BGMSlider
@onready var sfx_slider: HSlider = $SettingsModal/MarginContainer/VBoxContainer/SFXControl/SFXSlider
@onready var close_settings_btn: Button = $SettingsModal/MarginContainer/VBoxContainer/CloseSettingsButton

@onready var credits_modal: PanelContainer = $CreditsModal
@onready var close_credits_btn: Button = $CreditsModal/MarginContainer/VBoxContainer/CloseCreditsButton

@onready var confirm_new_game_modal: PanelContainer = $ConfirmNewGameModal
@onready var confirm_yes_btn: Button = $ConfirmNewGameModal/MarginContainer/VBoxContainer/HBoxContainer/YesButton
@onready var confirm_no_btn: Button = $ConfirmNewGameModal/MarginContainer/VBoxContainer/HBoxContainer/NoButton

func _ready() -> void:
	settings_modal.visible = false
	credits_modal.visible = false
	confirm_new_game_modal.visible = false
	
	# Status Tombol Lanjutkan Game
	var has_save = GameState.has_saved_profile()
	continue_btn.disabled = not has_save
	if has_save:
		continue_btn.text = "LANJUTKAN PERJALANAN\n(%s — Ch %d.%d)" % [
			GameState.player_name, 
			GameState.current_chapter, 
			GameState.current_mini_chapter
		]
	else:
		continue_btn.text = "LANJUTKAN PERJALANAN\n(Belum Ada Data)"
		
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	settings_btn.pressed.connect(func(): settings_modal.visible = true)
	credits_btn.pressed.connect(func(): credits_modal.visible = true)
	
	close_settings_btn.pressed.connect(func(): settings_modal.visible = false)
	close_credits_btn.pressed.connect(func(): credits_modal.visible = false)
	
	confirm_yes_btn.pressed.connect(_on_confirm_new_game_yes)
	confirm_no_btn.pressed.connect(func(): confirm_new_game_modal.visible = false)
	
	# Setup Audio Sliders
	bgm_slider.value = db_to_linear(AudioManager.bgm_player.volume_db) * 100
	sfx_slider.value = db_to_linear(AudioManager.sfx_player.volume_db) * 100
	
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _on_continue_pressed() -> void:
	AudioManager.play_card_sfx()
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")

func _on_new_game_pressed() -> void:
	AudioManager.play_card_sfx()
	if GameState.has_saved_profile():
		confirm_new_game_modal.visible = true
	else:
		_start_fresh_game()

func _on_confirm_new_game_yes() -> void:
	AudioManager.play_card_sfx()
	confirm_new_game_modal.visible = false
	_start_fresh_game()

func _start_fresh_game() -> void:
	GameState.hard_reset_entire_game()
	get_tree().change_scene_to_file("res://scenes/NameCreation.tscn")

func _on_bgm_slider_changed(val: float) -> void:
	var lin = val / 100.0
	if lin <= 0.01:
		AudioManager.bgm_player.volume_db = -80.0
	else:
		AudioManager.bgm_player.volume_db = linear_to_db(lin)

func _on_sfx_slider_changed(val: float) -> void:
	var lin = val / 100.0
	if lin <= 0.01:
		AudioManager.sfx_player.volume_db = -80.0
	else:
		AudioManager.sfx_player.volume_db = linear_to_db(lin)
	AudioManager.play_coin_sfx()
