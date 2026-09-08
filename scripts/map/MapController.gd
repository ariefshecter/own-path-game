extends Control

const NODE_BTN_SCRIPT = preload("res://scripts/map/MapNodeButton.gd")
const MAP_GEN = preload("res://scripts/map/MapGenerator.gd")

@onready var floors_container: VBoxContainer = $ScrollContainer/FloorsContainer
@onready var header_info: Label = $TopBar/HeaderInfo
@onready var status_info: Label = $TopBar/StatusInfo

func _ready() -> void:
	if GameState.map_floors.is_empty():
		GameState.map_floors = MAP_GEN.generate_mini_chapter_map()
	render_map()

func render_map() -> void:
	# Bersihkan child lama
	for child in floors_container.get_children():
		child.queue_free()
		
	header_info.text = "Chapter %d — Bagian %d (Lantai %d/%d)" % [
		GameState.current_chapter, 
		GameState.current_mini_chapter, 
		GameState.current_floor,
		GameState.max_floors
	]
	
	status_info.text = "Mental: %d/%d  |  Koin Run: %d  |  Tabungan Bank: %d" % [
		GameState.player_sanity,
		GameState.player_max_sanity,
		GameState.run_coins,
		GameState.permanent_savings
	]
	
	# Peta digambar dari Lantai 5 (atas) ke Lantai 1 (bawah)
	for floor_idx in range(4, -1, -1):
		var floor_num = floor_idx + 1
		var floor_row = HBoxContainer.new()
		floor_row.alignment = BoxContainer.ALIGNMENT_CENTER
		floor_row.add_theme_constant_override("separation", 40)
		
		var floor_label = Label.new()
		floor_label.text = "Lt. %d" % floor_num
		floor_label.custom_minimum_size = Vector2(80, 0)
		floor_row.add_child(floor_label)
		
		var nodes = GameState.map_floors[floor_idx]
		for n_data in nodes:
			var btn = Button.new()
			btn.set_script(NODE_BTN_SCRIPT)
			btn.custom_minimum_size = Vector2(220, 100)
			
			var is_current = (n_data["id"] == GameState.current_node_id)
			var reachable = is_node_reachable(n_data)
			
			btn.setup(n_data, reachable, is_current)
			btn.node_selected.connect(_on_node_selected)
			floor_row.add_child(btn)
			
		floors_container.add_child(floor_row)
		
		# Pemisah antar lantai
		var sep = HSeparator.new()
		floors_container.add_child(sep)

func is_node_reachable(n_data: Dictionary) -> bool:
	var target_floor = n_data.get("floor", 1)
	
	# Jika baru mulai run (Lantai 1), semua node di Lantai 1 bisa dipilih
	if GameState.current_node_id == "":
		return target_floor == 1
		
	# Harus persis di lantai berikutnya
	if target_floor != GameState.current_floor + 1:
		return false
		
	# Cek apakah terhubung dari current_node_id
	var current_node = find_node_by_id(GameState.current_node_id)
	if current_node.is_empty():
		return false
		
	return n_data["id"] in current_node.get("connections", [])

func find_node_by_id(n_id: String) -> Dictionary:
	for fl in GameState.map_floors:
		for n in fl:
			if n["id"] == n_id:
				return n
	return {}

func _on_node_selected(n_data: Dictionary) -> void:
	GameState.current_node_id = n_data["id"]
	GameState.current_floor = n_data["floor"]
	var n_type = n_data["type"]
	
	print("Menuju Node: ", n_data["title"], " (Tipe: ", n_type, ")")
	
	# Routing ke scene berdasarkan tipe node
	if n_type == 0: # BATTLE
		get_tree().change_scene_to_file("res://scenes/Battle.tscn")
	elif n_type == 1: # EVENT
		# Event sementara kembali render map
		render_map()
	elif n_type == 2: # SHOP
		get_tree().change_scene_to_file("res://scenes/ShopScreen.tscn")
