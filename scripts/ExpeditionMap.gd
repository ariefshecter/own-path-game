extends Control

const NODE_BTN_SCRIPT = preload("res://scripts/map/ExpeditionNodeButton.gd")
const EXP_GEN = preload("res://scripts/map/ExpeditionGenerator.gd")

@onready var steps_container: VBoxContainer = $ScrollContainer/StepsContainer
@onready var header_info: Label = $TopBar/HeaderInfo
@onready var status_info: Label = $TopBar/StatusInfo
@onready var room_hub_btn: Button = $TopBar/RoomHubButton

var floor_steps: Array = []

func _ready() -> void:
	room_hub_btn.pressed.connect(_on_room_hub_pressed)
	
	if floor_steps.is_empty():
		# Buat 4 langkah untuk Lantai 1
		floor_steps = EXP_GEN.generate_floor_graph(4)
		GameState.max_steps = 4
		
	render_expedition_map()

func render_expedition_map() -> void:
	for child in steps_container.get_children():
		child.queue_free()
		
	header_info.text = "Chapter %d — Bagian %d.%d (Lantai Ekspedisi %d/3)" % [
		GameState.current_chapter,
		GameState.current_chapter,
		GameState.current_mini_chapter,
		GameState.current_expedition_floor
	]
	
	status_info.text = "Mental: %d/%d  |  Koin Run: %d  |  Tabungan Bank: %d" % [
		GameState.player_sanity,
		GameState.player_max_sanity,
		GameState.run_coins,
		GameState.permanent_savings
	]
	
	# Render dari Langkah terakhir (Langkah 4 di atas) ke Langkah 1 di bawah (Bottom-up ala Arknights IS)
	for s_idx in range(floor_steps.size() - 1, -1, -1):
		var step_num = s_idx + 1
		var step_row = HBoxContainer.new()
		step_row.alignment = BoxContainer.ALIGNMENT_CENTER
		step_row.add_theme_constant_override("separation", 36)
		
		var step_label = Label.new()
		step_label.text = "Tahap %d" % step_num
		step_label.custom_minimum_size = Vector2(90, 0)
		step_row.add_child(step_label)
		
		var nodes = floor_steps[s_idx]
		for n_data in nodes:
			var btn = Button.new()
			btn.set_script(NODE_BTN_SCRIPT)
			btn.custom_minimum_size = Vector2(250, 95)
			
			var is_current = (n_data["id"] == GameState.current_node_id)
			var is_active = is_node_reachable(n_data)
			
			btn.setup(n_data, is_active, is_current)
			btn.stage_selected.connect(_on_stage_selected)
			step_row.add_child(btn)
			
		steps_container.add_child(step_row)
		
		# Garis pemisah antar langkah
		var sep = HSeparator.new()
		steps_container.add_child(sep)

func is_node_reachable(n_data: Dictionary) -> bool:
	var target_step = n_data.get("step", 1)
	
	# Langkah 1 selalu bisa dipilih saat baru mulai
	if GameState.current_node_id == "":
		return target_step == 1
		
	# Hanya boleh langkah persis berikutnya
	if target_step != GameState.current_step + 1:
		return false
		
	var curr_node = find_node_by_id(GameState.current_node_id)
	if curr_node.is_empty():
		return false
		
	return n_data["id"] in curr_node.get("connections", [])

func find_node_by_id(n_id: String) -> Dictionary:
	for st in floor_steps:
		for n in st:
			if n["id"] == n_id:
				return n
	return {}

func _on_stage_selected(stage_data: Dictionary) -> void:
	AudioManager.play_card_sfx()
	GameState.current_node_id = stage_data["id"]
	GameState.current_step = stage_data["step"]
	var stype = stage_data["type"]
	
	print("Menjalankan Stage: ", stage_data["title"], " (Tipe: ", stype, ")")
	
	# Routing ke scene stage yang sesuai
	match stype:
		0: # BATTLE
			get_tree().change_scene_to_file("res://scenes/Battle.tscn")
		1: # COFFEE (REST / HEAL)
			_handle_coffee_event()
		2: # SHOP
			get_tree().change_scene_to_file("res://scenes/ShopScreen.tscn")
		3: # DILEMMA
			get_tree().change_scene_to_file("res://scenes/EventScreen.tscn")

func _handle_coffee_event() -> void:
	AudioManager.play_coin_sfx()
	GameState.player_sanity = min(GameState.player_max_sanity, GameState.player_sanity + 15)
	GameState.run_coins += 10
	print("Kopi seduh kampus: Mental +15, Koin +10!")
	render_expedition_map()

func _on_room_hub_pressed() -> void:
	AudioManager.play_card_sfx()
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")
