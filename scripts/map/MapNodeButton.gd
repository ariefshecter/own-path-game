extends Button

signal node_selected(node_data)

var node_data: Dictionary = {}
var is_reachable: bool = false

func setup(data: Dictionary, reachable: bool, is_current: bool) -> void:
	node_data = data
	is_reachable = reachable
	
	var type_name = "Stage"
	var type = data.get("type", 0)
	if type == 0:
		type_name = "⚔️ Masalah"
	elif type == 1:
		type_name = "✉️ Dilema"
	elif type == 2:
		type_name = "🏪 Kios/Bank"
		
	text = "%s\n[%s]" % [data.get("title", "Jalur"), type_name]
	
	if is_current:
		modulate = Color(0.3, 1.0, 0.4) # Hijau penanda posisi saat ini
		disabled = true
	elif reachable:
		modulate = Color(1.0, 0.85, 0.3) # Emas: Siap dipilih
		disabled = false
	else:
		modulate = Color(0.4, 0.4, 0.45) # Abu-abu: Belum terjangkau
		disabled = true

func _pressed() -> void:
	if is_reachable:
		node_selected.emit(node_data)
