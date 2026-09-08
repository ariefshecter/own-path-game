extends PanelContainer

signal card_clicked(card_ui)

var card_data: Dictionary = {}
var is_playable: bool = true
var is_hovered: bool = false

@onready var cost_label: Label = $MarginContainer/VBoxContainer/Header/CostLabel
@onready var title_label: Label = $MarginContainer/VBoxContainer/Header/TitleLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescLabel
@onready var flavor_label: Label = $MarginContainer/VBoxContainer/FlavorLabel

func _ready() -> void:
	pivot_offset = size / 2.0
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(data: Dictionary) -> void:
	card_data = data
	cost_label.text = str(data.get("energy_cost", 1))
	title_label.text = str(data.get("name", "Aksi"))
	
	var desc = ""
	for eff in data.get("effects", []):
		var val = eff.get("value", 0)
		var etype = eff.get("type", "")
		if etype == "DAMAGE":
			desc += "Serang %d\n" % val
		elif etype == "SHIELD":
			desc += "Perisai +%d\n" % val
		elif etype == "GAIN_COINS":
			desc += "Koin +%d\n" % val
		elif etype == "GAIN_ENERGY":
			desc += "Energi +%d\n" % val
	desc_label.text = desc.strip_edges()
	flavor_label.text = str(data.get("flavor", ""))

func set_playable(playable: bool) -> void:
	is_playable = playable
	if not is_hovered:
		modulate = Color.WHITE if playable else Color(0.65, 0.65, 0.65, 0.85)

func _on_mouse_entered() -> void:
	if not is_playable:
		return
	is_hovered = true
	pivot_offset = size / 2.0
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position:y", -24.0, 0.15)
	tween.parallel().tween_property(self, "scale", Vector2(1.06, 1.06), 0.15)

func _on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position:y", 0.0, 0.15)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	set_playable(is_playable)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_playable:
			# Efek klik menekan sekejap
			var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.08)
			tween.tween_callback(func(): card_clicked.emit(self))
