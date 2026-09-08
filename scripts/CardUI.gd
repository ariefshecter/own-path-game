extends PanelContainer

signal card_clicked(card_ui)

var card_data: Dictionary = {}
var is_playable: bool = true

@onready var cost_label: Label = $MarginContainer/VBoxContainer/Header/CostLabel
@onready var title_label: Label = $MarginContainer/VBoxContainer/Header/TitleLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescLabel
@onready var flavor_label: Label = $MarginContainer/VBoxContainer/FlavorLabel

func setup(data: Dictionary) -> void:
	card_data = data
	cost_label.text = str(data.get("energy_cost", 1))
	title_label.text = str(data.get("name", "Aksi"))
	
	var desc = ""
	for eff in data.get("effects", []):
		var target = eff.get("target", "")
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
	modulate = Color.WHITE if playable else Color(0.5, 0.5, 0.5, 0.8)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_playable:
			card_clicked.emit(self)
