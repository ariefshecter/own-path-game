extends Control

@onready var room_title: Label = $TopArea/RoomTitle
@onready var status_label: Label = $TopArea/StatusLabel
@onready var chapter_picker_box: HBoxContainer = $ChapterSelectionBox/ButtonsContainer
@onready var upgrade_1_btn: Button = $UpgradesBox/Upgrade1Box/Upgrade1Button
@onready var upgrade_1_info: Label = $UpgradesBox/Upgrade1Box/Upgrade1Info
@onready var upgrade_2_btn: Button = $UpgradesBox/Upgrade2Box/Upgrade2Button
@onready var upgrade_2_info: Label = $UpgradesBox/Upgrade2Box/Upgrade2Info
@onready var start_run_btn: Button = $BottomArea/StartRunButton
@onready var log_label: Label = $BottomArea/LogLabel

var selected_mini_chapter: int = 1

const COST_SANITY_UPGRADE = 60
const COST_ENERGY_UPGRADE = 120

func _ready() -> void:
	selected_mini_chapter = GameState.current_mini_chapter
	render_chapter_picker()
	update_ui()
	
	upgrade_1_btn.pressed.connect(_on_buy_sanity_upgrade)
	upgrade_2_btn.pressed.connect(_on_buy_energy_upgrade)
	start_run_btn.pressed.connect(_on_start_run)

func render_chapter_picker() -> void:
	for child in chapter_picker_box.get_children():
		child.queue_free()
		
	for i in range(1, 6):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(140, 70)
		btn.text = "Bagian 1.%d" % i
		
		if i <= GameState.max_unlocked_mini_chapter:
			btn.disabled = false
			if i == selected_mini_chapter:
				btn.modulate = Color(0.2, 0.8, 0.3) # Hijau terpilih
			else:
				btn.modulate = Color(1.0, 0.9, 0.5) # Emas terbuka
		else:
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5) # Terkunci
			btn.text += "\n🔒"
			
		var mc_idx = i
		btn.pressed.connect(func():
			selected_mini_chapter = mc_idx
			GameState.current_mini_chapter = mc_idx
			render_chapter_picker()
			log_label.text = "Memilih tujuan: Chapter 1 Bagian 1.%d" % mc_idx
		)
		chapter_picker_box.add_child(btn)

func update_ui() -> void:
	room_title.text = "🏠 KAMAR KOS %s" % GameState.player_name.to_upper()
	status_label.text = "Kapasitas Mental: %d  |  Buku Tabungan Bank: %d Koin" % [
		GameState.player_max_sanity,
		GameState.permanent_savings
	]
	
	# Upgrade 1: Kapasitas Mental Dasar
	var has_upg1 = "sanity_boost" in GameState.purchased_meta_upgrades
	if has_upg1:
		upgrade_1_btn.disabled = true
		upgrade_1_btn.text = "SUDAH DIBELI"
		upgrade_1_info.text = "Kasur Lipat Nyaman (+10 Mental Permanen) [AKTIF]"
	else:
		upgrade_1_info.text = "Beli Kasur Lipat (+10 Mental Permanen) — Biaya: %d Koin" % COST_SANITY_UPGRADE
		upgrade_1_btn.text = "UPGRADE"
		upgrade_1_btn.disabled = (GameState.permanent_savings < COST_SANITY_UPGRADE)
		
	# Upgrade 2: Kartu Motivasi
	var has_upg2 = "card_focus_unlock" in GameState.purchased_meta_upgrades
	if has_upg2:
		upgrade_2_btn.disabled = true
		upgrade_2_btn.text = "SUDAH DIBELI"
		upgrade_2_info.text = "Buku Catatan Impian (Buka Kartu 'Kuatkan Tekad') [AKTIF]"
	else:
		upgrade_2_info.text = "Buku Catatan Impian (Buka Kartu 'Kuatkan Tekad') — Biaya: %d Koin" % COST_ENERGY_UPGRADE
		upgrade_2_btn.text = "UPGRADE"
		upgrade_2_btn.disabled = (GameState.permanent_savings < COST_ENERGY_UPGRADE)
		
	start_run_btn.text = "MELANGKAH KE MINI CHAPTER 1.%d" % selected_mini_chapter

func _on_buy_sanity_upgrade() -> void:
	if GameState.permanent_savings >= COST_SANITY_UPGRADE:
		AudioManager.play_coin_sfx()
		GameState.permanent_savings -= COST_SANITY_UPGRADE
		GameState.player_max_sanity += 10
		GameState.player_sanity = GameState.player_max_sanity
		GameState.purchased_meta_upgrades.append("sanity_boost")
		GameState.save_game()
		log_label.text = "Tidurmu lebih nyenyak! Kapasitas mental maksimal bertambah 10!"
		update_ui()

func _on_buy_energy_upgrade() -> void:
	if GameState.permanent_savings >= COST_ENERGY_UPGRADE:
		AudioManager.play_coin_sfx()
		GameState.permanent_savings -= COST_ENERGY_UPGRADE
		GameState.deck.append("card_focus")
		GameState.purchased_meta_upgrades.append("card_focus_unlock")
		GameState.save_game()
		log_label.text = "Menuliskan impian! Kartu 'Kuatkan Tekad' kini masuk ke deck awalmu!"
		update_ui()

func _on_start_run() -> void:
	GameState.current_mini_chapter = selected_mini_chapter
	GameState.current_floor = 1
	GameState.current_expedition_floor = 1
	GameState.current_step = 0
	GameState.player_sanity = GameState.player_max_sanity
	GameState.run_coins = 50
	GameState.map_floors.clear()
	GameState.current_node_id = ""
	get_tree().change_scene_to_file("res://scenes/ExpeditionMap.tscn")
