class_name MapGenerator
extends RefCounted

# Tipe Stage Node
enum NodeType {
	BATTLE,  # Tantangan Utama / Pertarungan kartu
	EVENT,   # Dilema Hidup / Pilihan acak naratif
	SHOP     # Kios Toko & Konter Bank Tabungan
}

# Menghasilkan struktur 5 lantai acak dengan percabangan
static func generate_mini_chapter_map() -> Array:
	var floors: Array = []
	
	# Konfigurasi jumlah node per lantai (1 sampai 5)
	# Lantai 1: 2 node (Battle awal)
	# Lantai 2: 2-3 node (Campuran)
	# Lantai 3: 3 node (Pusat variasi: Shop/Event/Battle)
	# Lantai 4: 2 node (Shop atau Event krusial sebelum bos)
	# Lantai 5: 1 node (Puncak tantangan / Bos mini chapter)
	var node_counts = [2, 3, 3, 2, 1]
	
	for floor_idx in range(5):
		var count = node_counts[floor_idx]
		var current_floor_nodes: Array = []
		
		for node_idx in range(count):
			var n_id = "f%d_n%d" % [floor_idx + 1, node_idx + 1]
			var n_type = _determine_node_type(floor_idx + 1, node_idx, count)
			var n_title = _get_node_title(n_type, floor_idx + 1)
			
			current_floor_nodes.append({
				"id": n_id,
				"floor": floor_idx + 1,
				"index": node_idx,
				"type": n_type,
				"title": n_title,
				"connections": [] # ID node yang terhubung di lantai berikutnya
			})
			
		floors.append(current_floor_nodes)
		
	# Hubungkan koneksi antar lantai (Lantai N ke N+1)
	for floor_idx in range(4):
		var curr_nodes = floors[floor_idx]
		var next_nodes = floors[floor_idx + 1]
		
		for c_node in curr_nodes:
			# Setiap node setidaknya terhubung ke 1-2 node di atasnya
			if next_nodes.size() == 1:
				c_node["connections"].append(next_nodes[0]["id"])
			elif curr_nodes.size() == next_nodes.size():
				c_node["connections"].append(next_nodes[c_node["index"]]["id"])
				# Sambungan diagonal acak
				if c_node["index"] + 1 < next_nodes.size() and randf() > 0.5:
					c_node["connections"].append(next_nodes[c_node["index"] + 1]["id"])
			elif curr_nodes.size() < next_nodes.size():
				c_node["connections"].append(next_nodes[c_node["index"]]["id"])
				c_node["connections"].append(next_nodes[c_node["index"] + 1]["id"])
			else: # curr_nodes.size() > next_nodes.size()
				var target_idx = min(c_node["index"], next_nodes.size() - 1)
				c_node["connections"].append(next_nodes[target_idx]["id"])
				
	return floors

static func _determine_node_type(floor_num: int, node_idx: int, total_nodes: int) -> int:
	if floor_num == 1:
		return NodeType.BATTLE
	elif floor_num == 5:
		return NodeType.BATTLE # Bos akhir lantai 5
	elif floor_num == 4:
		return NodeType.SHOP if node_idx == 0 else NodeType.EVENT
	else:
		var roll = randf()
		if roll < 0.50:
			return NodeType.BATTLE
		elif roll < 0.80:
			return NodeType.EVENT
		else:
			return NodeType.SHOP

static func _get_node_title(type: int, floor_num: int) -> String:
	if floor_num == 5:
		return "Ujian Penentuan"
	match type:
		NodeType.BATTLE:
			return "Beban Pikiran"
		NodeType.EVENT:
			return "Dilema Nyata"
		NodeType.SHOP:
			return "Kios & Bank"
	return "Jalan"
