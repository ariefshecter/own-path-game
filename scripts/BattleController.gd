extends Control

const CARD_UI_SCENE = preload("res://scenes/CardUI.tscn")

# Nodes
@onready var enemy_title: Label = $TopArea/EnemyBox/EnemyTitle
@onready var enemy_hp_label: Label = $TopArea/EnemyBox/EnemyHPLabel
@onready var enemy_intent_label: Label = $TopArea/EnemyBox/EnemyIntentLabel
@onready var player_sanity_label: Label = $MidArea/PlayerStatus/SanityLabel
@onready var player_shield_label: Label = $MidArea/PlayerStatus/ShieldLabel
@onready var player_energy_label: Label = $MidArea/PlayerStatus/EnergyLabel
@onready var run_coins_label: Label = $MidArea/PlayerStatus/CoinsLabel
@onready var hand_container: HBoxContainer = $BottomArea/ScrollContainer/HandContainer
@onready var end_turn_btn: Button = $BottomArea/EndTurnButton
@onready var log_label: Label = $MidArea/LogLabel

# State
var player_sanity: int = 50
var player_max_sanity: int = 50
var player_energy: int = 3
var player_max_energy: int = 3
var player_shield: int = 0
var run_coins: int = 0

var enemy_data: Dictionary = {}
var enemy_hp: int = 30
var enemy_action_idx: int = 0

var deck: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var cards_map: Dictionary = {}

func _ready() -> void:
	load_data()
	end_turn_btn.pressed.connect(_on_end_turn_pressed)
	start_battle(enemy_data)

func load_data() -> void:
	var file = FileAccess.open("res://data/cards.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Array:
			for c in parsed:
				cards_map[c["id"]] = c
				
	var enemy_file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if enemy_file:
		var parsed = JSON.parse_string(enemy_file.get_as_text())
		if parsed is Array and parsed.size() > 0:
			# Filter musuh sesuai lantai & mini chapter
			var candidates = []
			for en in parsed:
				if GameState.current_floor == 5 and en.get("is_boss", false):
					candidates.append(en)
				elif GameState.current_floor < 5 and not en.get("is_boss", false):
					candidates.append(en)
			if candidates.is_empty():
				candidates = parsed
			enemy_data = candidates[randi() % candidates.size()]
			
	if GameState.deck.is_empty():
		deck = [
			"card_refuse", "card_refuse", "card_breathe", 
			"card_breathe", "card_overtime", "card_coffee", "card_ignore_call"
		]
	else:
		deck = GameState.deck.duplicate()

func start_battle(enemy: Dictionary) -> void:
	enemy_data = enemy
	enemy_hp = enemy.get("resolve_hp", 30)
	enemy_action_idx = 0
	
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
	
	player_sanity = player_max_sanity
	player_energy = player_max_energy
	player_shield = 0
	
	update_ui()
	start_player_turn()

func start_player_turn() -> void:
	player_energy = player_max_energy
	player_shield = 0 # Shield reset tiap awal giliran
	
	# Draw 4 kartu
	for i in range(4):
		if draw_pile.is_empty():
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
		if not draw_pile.is_empty():
			var card_id = draw_pile.pop_back()
			add_card_to_hand(card_id)
			
	update_ui()
	log_label.text = "Giliranmu dimulai. Pilih tindakan untuk bertahan."

func add_card_to_hand(card_id: String) -> void:
	var c_data = cards_map.get(card_id, {})
	if c_data.is_empty():
		return
	var card_ui = CARD_UI_SCENE.instantiate()
	hand_container.add_child(card_ui)
	card_ui.setup(c_data)
	card_ui.card_clicked.connect(_on_card_clicked)

func _on_card_clicked(card_ui) -> void:
	var cost = card_ui.card_data.get("energy_cost", 1)
	if player_energy < cost:
		log_label.text = "Energi harianmu tidak cukup!"
		return
		
	player_energy -= cost
	var effects = card_ui.card_data.get("effects", [])
	for eff in effects:
		apply_effect(eff)
		
	discard_pile.append(card_ui.card_data.get("id"))
	card_ui.queue_free()
	
	update_ui()
	
	if enemy_hp <= 0:
		on_victory()

func apply_effect(eff: Dictionary) -> void:
	var target = eff.get("target", "")
	var val = eff.get("value", 0)
	var etype = eff.get("type", "")
	
	if etype == "DAMAGE" and target == "ENEMY":
		enemy_hp = max(0, enemy_hp - val)
	elif etype == "SHIELD" and target == "SELF":
		player_shield += val
	elif etype == "GAIN_COINS" and target == "SELF":
		run_coins += val
	elif etype == "GAIN_ENERGY" and target == "SELF":
		player_energy += val
	elif etype == "DAMAGE" and target == "SELF":
		player_sanity = max(0, player_sanity - val)

func _on_end_turn_pressed() -> void:
	# Buang semua kartu tersisa di tangan
	for child in hand_container.get_children():
		discard_pile.append(child.card_data.get("id"))
		child.queue_free()
		
	execute_enemy_turn()

func execute_enemy_turn() -> void:
	if enemy_hp <= 0:
		return
		
	var actions = enemy_data.get("actions", [])
	if actions.is_empty():
		return
		
	var act = actions[enemy_action_idx % actions.size()]
	var intent = act.get("intent", "ATTACK")
	var val = act.get("value", 5)
	var dialogue = act.get("dialogue", "...")
	
	log_label.text = "%s: %s" % [enemy_data.get("name", "Musuh"), dialogue]
	
	if intent == "ATTACK":
		var blocked = min(player_shield, val)
		var unblocked = val - blocked
		player_shield -= blocked
		player_sanity = max(0, player_sanity - unblocked)
	elif intent == "DEFEND":
		# Musuh menambah armor jika ada
		pass
		
	enemy_action_idx += 1
	update_ui()
	
	if player_sanity <= 0:
		on_defeat()
	else:
		start_player_turn()

func on_victory() -> void:
	run_coins += 25
	GameState.run_coins += 25
	GameState.player_sanity = player_sanity
	log_label.text = "Kamu berhasil melewati tekanan ini! (+25 Koin Run)"
	
	end_turn_btn.disabled = false
	end_turn_btn.pressed.disconnect(_on_end_turn_pressed)
	
	# Cek apakah ini bos lantai 5 mini chapter 5 (Tamat Chapter 1)
	if GameState.current_floor == 5 and GameState.current_mini_chapter == 5 and GameState.current_chapter == 1:
		end_turn_btn.text = "CHAPTER 1 SELESAI"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ChapterClear.tscn"))
	elif GameState.current_floor == 5:
		# Mini chapter selesai, simpan & lanjut ke mini chapter berikutnya
		GameState.advance_mini_chapter()
		end_turn_btn.text = "MINI CHAPTER BERIKUTNYA"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MapScreen.tscn"))
	else:
		end_turn_btn.text = "LANJUT MELANGKAH"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MapScreen.tscn"))

func on_defeat() -> void:
	# Pindah ke adegan desakan orang tua
	get_tree().change_scene_to_file("res://scenes/ParentPressure.tscn")

func update_ui() -> void:
	enemy_title.text = str(enemy_data.get("name", "Masalah"))
	enemy_hp_label.text = "Ketahanan Tekanan: %d" % enemy_hp
	
	var actions = enemy_data.get("actions", [])
	if not actions.is_empty():
		var act = actions[enemy_action_idx % actions.size()]
		enemy_intent_label.text = "Niat: %s (%d)" % [act.get("intent"), act.get("value")]
		
	player_sanity_label.text = "Mental: %d/%d" % [player_sanity, player_max_sanity]
	player_shield_label.text = "Perisai: %d" % player_shield
	player_energy_label.text = "Energi: %d/%d" % [player_energy, player_max_energy]
	run_coins_label.text = "Koin Run: %d" % run_coins
	
	# Update status playability kartu di tangan
	for child in hand_container.get_children():
		if child.has_method("set_playable"):
			var cost = child.card_data.get("energy_cost", 1)
			child.set_playable(player_energy >= cost)
