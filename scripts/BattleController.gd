extends Control

const CARD_UI_SCENE = preload("res://scenes/CardUI.tscn")

# Sprite assets
const SPRITE_FATHER = preload("res://assets/sprites/father.png")
const SPRITE_MOTHER = preload("res://assets/sprites/mother.png")
const SPRITE_TETANGGA = preload("res://assets/sprites/tetangga_julid.png")
const SPRITE_PAK_RT = preload("res://assets/sprites/pak_rt.png")

# Nodes
@onready var enemy_title: Label = $TopArea/EnemyBox/EnemyHeader/EnemyTitle
@onready var enemy_portrait: TextureRect = $TopArea/EnemyBox/EnemyHeader/EnemyPortrait
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
	
	# Pasang portrait musuh sesuai ID
	var en_id = enemy.get("id", "")
	if en_id == "enemy_boss_father_shadow":
		enemy_portrait.texture = SPRITE_FATHER
	elif en_id == "enemy_family_call" or en_id == "enemy_guilt":
		enemy_portrait.texture = SPRITE_MOTHER
	elif en_id == "enemy_tetangga_julid":
		enemy_portrait.texture = SPRITE_TETANGGA
	elif en_id == "enemy_birokrasi_kos":
		enemy_portrait.texture = SPRITE_PAK_RT
	else:
		enemy_portrait.texture = SPRITE_MOTHER
	
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
	
	player_sanity = GameState.player_sanity
	player_max_sanity = GameState.player_max_sanity
	player_energy = player_max_energy
	player_shield = 0
	run_coins = GameState.run_coins
	
	update_ui()
	start_player_turn()

func start_player_turn() -> void:
	player_energy = player_max_energy
	player_shield = 0
	
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
		# Animasi hentakan musuh saat terkena serangan
		animate_enemy_hit()
	elif etype == "SHIELD" and target == "SELF":
		player_shield += val
		animate_player_shield()
	elif etype == "GAIN_COINS" and target == "SELF":
		run_coins += val
		GameState.run_coins = run_coins
	elif etype == "GAIN_ENERGY" and target == "SELF":
		player_energy += val
	elif etype == "DAMAGE" and target == "SELF":
		player_sanity = max(0, player_sanity - val)
		GameState.player_sanity = player_sanity

func _on_end_turn_pressed() -> void:
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
		GameState.player_sanity = player_sanity
		# Animasi hentakan musuh menyerang & player terkena dampak
		animate_enemy_attack()
		if unblocked > 0:
			animate_player_damage()
	elif intent == "DEFEND":
		enemy_hp += val
		log_label.text = "%s memperkuat pertahanan psikologisnya (+%d Ketahanan)!" % [enemy_data.get("name"), val]
		
	enemy_action_idx += 1
	update_ui()
	
	if player_sanity <= 0:
		on_defeat()
	else:
		start_player_turn()

func animate_enemy_hit() -> void:
	AudioManager.play_hit_sfx()
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(enemy_portrait, "modulate", Color(1.0, 0.3, 0.3), 0.08)
	tw.parallel().tween_property(enemy_portrait, "position:x", 12.0, 0.08)
	tw.tween_property(enemy_portrait, "modulate", Color.WHITE, 0.15)
	tw.parallel().tween_property(enemy_portrait, "position:x", 0.0, 0.15)

func animate_enemy_attack() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(enemy_portrait, "scale", Vector2(1.18, 1.18), 0.12)
	tw.tween_property(enemy_portrait, "scale", Vector2(1.0, 1.0), 0.15)

func animate_player_damage() -> void:
	AudioManager.play_hit_sfx()
	var tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(player_sanity_label, "modulate", Color(0.9, 0.2, 0.2), 0.1)
	tw.parallel().tween_property(player_sanity_label, "scale", Vector2(1.25, 1.25), 0.1)
	tw.tween_property(player_sanity_label, "modulate", Color.WHITE, 0.2)
	tw.parallel().tween_property(player_sanity_label, "scale", Vector2(1.0, 1.0), 0.2)

func animate_player_shield() -> void:
	AudioManager.play_shield_sfx()
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(player_shield_label, "modulate", Color(0.4, 0.8, 1.0), 0.1)
	tw.parallel().tween_property(player_shield_label, "scale", Vector2(1.25, 1.25), 0.1)
	tw.tween_property(player_shield_label, "modulate", Color.WHITE, 0.2)
	tw.parallel().tween_property(player_shield_label, "scale", Vector2(1.0, 1.0), 0.2)

func on_victory() -> void:
	run_coins += 25
	GameState.run_coins += 25
	GameState.player_sanity = player_sanity
	log_label.text = "Kamu berhasil melewati tekanan ini! (+25 Koin Run)"
	
	end_turn_btn.disabled = false
	end_turn_btn.pressed.disconnect(_on_end_turn_pressed)
	
	if GameState.current_floor == 5 and GameState.current_mini_chapter == 5 and GameState.current_chapter == 1:
		end_turn_btn.text = "CHAPTER 1 SELESAI"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ChapterClear.tscn"))
	elif GameState.current_floor == 5:
		GameState.advance_mini_chapter()
		end_turn_btn.text = "MINI CHAPTER BERIKUTNYA"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MapScreen.tscn"))
	else:
		end_turn_btn.text = "LANJUT MELANGKAH"
		end_turn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MapScreen.tscn"))

func on_defeat() -> void:
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
	
	for child in hand_container.get_children():
		if child.has_method("set_playable"):
			var cost = child.card_data.get("energy_cost", 1)
			child.set_playable(player_energy >= cost)
