extends Button

signal stage_selected(stage_data)

var stage_data: Dictionary = {}
var is_active: bool = false

func setup(data: Dictionary, active: bool, is_current: bool) -> void:
	stage_data = data
	is_active = active
	
	var type = data.get("type", 0)
	var prefix = ""
	match type:
		0: prefix = "⚔️ " # BATTLE
		1: prefix = "☕ " # COFFEE
		2: prefix = "🏪 " # SHOP
		3: prefix = "✉️ " # DILEMMA
		
	text = "%s%s" % [prefix, data.get("title", "Stage")]
	
	if is_current:
		modulate = Color(0.2, 0.85, 0.3) # Hijau: Langkah saat ini
		disabled = true
	elif active:
		modulate = Color(1.0, 0.9, 0.4) # Emas stiker: Siap dipilih
		disabled = false
	else:
		modulate = Color(0.7, 0.68, 0.65) # Terkunci
		disabled = true

func _pressed() -> void:
	if is_active:
		stage_selected.emit(stage_data)
