class_name ExpeditionGenerator
extends RefCounted

# Tipe Stage untuk Lantai 1 Mini Chapter 1.1
enum StageType {
	BATTLE,  # ⚔ Beban Skripsi
	COFFEE,  # ☕ Warung Kopi Kampus
	SHOP,    # 🏪 Fotokopi Barokah
	DILEMMA  # ✉ Dilema Nongkrong vs Koding
}

const STAGE_TITLES = {
	StageType.BATTLE: "Beban Skripsi Bab 4",
	StageType.COFFEE: "Kopi Belakang Kampus",
	StageType.SHOP: "Fotokopi & ATK Barokah",
	StageType.DILEMMA: "Dilema Ajakan Teman"
}

# Membuat struktur lantai dengan aturan non-repeating
# steps_count: 4 langkah untuk Lantai 1
static func generate_floor_graph(steps_count: int = 4) -> Array:
	var steps: Array = []
	
	for step_idx in range(steps_count):
		var step_nodes: Array = []
		# Tiap langkah memiliki 2-3 cabang pilihan
		var node_count = 2 if (step_idx == 0 or step_idx == steps_count - 1) else 3
		
		for n_idx in range(node_count):
			var node_id = "s%d_n%d" % [step_idx + 1, n_idx + 1]
			
			# Tentukan tipe stage dengan memastikan tidak ada tipe sama berulang berurutan dari parent
			var chosen_type = _pick_stage_type(step_idx, steps, n_idx)
			
			step_nodes.append({
				"id": node_id,
				"step": step_idx + 1,
				"index": n_idx,
				"type": chosen_type,
				"title": STAGE_TITLES[chosen_type],
				"connections": []
			})
			
		steps.append(step_nodes)
		
	# Hubungkan koneksi antar langkah (Langkah N ke N+1)
	for step_idx in range(steps_count - 1):
		var curr_step = steps[step_idx]
		var next_step = steps[step_idx + 1]
		
		for c_node in curr_step:
			if curr_step.size() == next_step.size():
				c_node["connections"].append(next_step[c_node["index"]]["id"])
				if c_node["index"] + 1 < next_step.size() and randf() > 0.4:
					c_node["connections"].append(next_step[c_node["index"] + 1]["id"])
			elif curr_step.size() < next_step.size():
				c_node["connections"].append(next_step[c_node["index"]]["id"])
				c_node["connections"].append(next_step[c_node["index"] + 1]["id"])
			else: # curr_step.size() > next_step.size()
				var target_idx = min(c_node["index"], next_step.size() - 1)
				c_node["connections"].append(next_step[target_idx]["id"])
				if c_node["index"] > 0 and randf() > 0.5:
					c_node["connections"].append(next_step[0]["id"])
					
	return steps

static func _pick_stage_type(step_idx: int, previous_steps: Array, node_idx: int) -> int:
	if step_idx == 0:
		# Langkah 1 selalu pilihan antara Battle ringan atau Warung Kopi
		return StageType.BATTLE if node_idx == 0 else StageType.COFFEE
		
	# Ambil tipe dari node pada langkah sebelumnya
	var prev_types = []
	if not previous_steps.is_empty():
		var last_step = previous_steps[previous_steps.size() - 1]
		for p_node in last_step:
			prev_types.append(p_node["type"])
			
	var all_types = [StageType.BATTLE, StageType.COFFEE, StageType.SHOP, StageType.DILEMMA]
	# Filter tipe yang dominan pada node sebelumnya untuk mencegah repetisi pada jalur yang sama
	var valid_candidates = []
	for t in all_types:
		if node_idx < prev_types.size() and prev_types[node_idx] == t:
			continue # Hindari tipe sama persis di indeks jalur sejajar
		valid_candidates.append(t)
		
	if valid_candidates.is_empty():
		valid_candidates = all_types
		
	return valid_candidates[randi() % valid_candidates.size()]
