extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var story_label: Label = $VBoxContainer/StoryPanel/MarginContainer/HBoxContainer/StoryLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/StoryPanel/MarginContainer/HBoxContainer/PortraitRect
@onready var option_1_btn: Button = $VBoxContainer/OptionsBox/Option1Button
@onready var option_2_btn: Button = $VBoxContainer/OptionsBox/Option2Button
@onready var result_panel: PanelContainer = $VBoxContainer/ResultPanel
@onready var result_label: Label = $VBoxContainer/ResultPanel/ResultLabel
@onready var continue_btn: Button = $VBoxContainer/ContinueButton
@onready var status_label: Label = $TopBar/StatusLabel

const SPRITE_CAFE_GIRL = preload("res://assets/sprites/cafe_girl.png")
const SPRITE_CAT = preload("res://assets/sprites/kucing_oren.png")
const SPRITE_UNCLE = preload("res://assets/sprites/uncle.png")

var current_event: Dictionary = {}

func _ready() -> void:
	result_panel.visible = false
	continue_btn.visible = false
	
	option_1_btn.pressed.connect(func(): _on_option_selected(0))
	option_2_btn.pressed.connect(func(): _on_option_selected(1))
	continue_btn.pressed.connect(_on_continue_pressed)
	
	load_random_event()
	update_status_bar()

func update_status_bar() -> void:
	status_label.text = "Mental: %d/%d  |  Koin Run: %d  |  Tabungan Bank: %d" % [
		GameState.player_sanity,
		GameState.player_max_sanity,
		GameState.run_coins,
		GameState.permanent_savings
	]

func load_random_event() -> void:
	var file = FileAccess.open("res://data/events.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Array and not parsed.is_empty():
			current_event = parsed[randi() % parsed.size()]
			
	title_label.text = "✉️ " + current_event.get("title", "Dilema Hidup")
	story_label.text = current_event.get("story", "...")
	
	var ev_id = current_event.get("id", "")
	if ev_id == "event_warung_kopi":
		portrait_rect.texture = SPRITE_CAFE_GIRL
		portrait_rect.visible = true
	elif ev_id == "event_kucing_tersesat":
		portrait_rect.texture = SPRITE_CAT
		portrait_rect.visible = true
	elif ev_id == "event_paman_jauh":
		portrait_rect.texture = SPRITE_UNCLE
		portrait_rect.visible = true
	else:
		portrait_rect.visible = false
	
	var options = current_event.get("options", [])
	if options.size() >= 2:
		option_1_btn.text = options[0].get("text", "Pilihan 1")
		option_2_btn.text = options[1].get("text", "Pilihan 2")
		
		var cost = options[0].get("cost_coins", 0)
		if GameState.run_coins < cost:
			option_1_btn.disabled = true
			option_1_btn.text += " (Koin Tidak Cukup)"
		else:
			option_1_btn.disabled = false

func _on_option_selected(idx: int) -> void:
	var options = current_event.get("options", [])
	if idx >= options.size():
		return
		
	var opt = options[idx]
	var cost = opt.get("cost_coins", 0)
	var rew_mental = opt.get("reward_mental", 0)
	var rew_card = opt.get("reward_card", null)
	var res_text = opt.get("result_text", "Kamu melanjutkan langkah.")
	
	GameState.run_coins = max(0, GameState.run_coins - cost)
	GameState.player_sanity = clamp(
		GameState.player_sanity + rew_mental, 
		1, 
		GameState.player_max_sanity
	)
	
	if rew_card != null and rew_card != "":
		GameState.deck.append(rew_card)
		
	option_1_btn.visible = false
	option_2_btn.visible = false
	result_panel.visible = true
	result_label.text = res_text
	continue_btn.visible = true
	
	update_status_bar()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ExpeditionMap.tscn")
