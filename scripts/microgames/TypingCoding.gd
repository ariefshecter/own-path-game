extends PanelContainer

signal coding_completed

@onready var code_label: RichTextLabel = $MarginContainer/VBoxContainer/CodeBox/CodeLabel
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var instruction_label: Label = $MarginContainer/VBoxContainer/InstructionLabel
@onready var type_button: Button = $MarginContainer/VBoxContainer/TypeButton

var code_lines: Array = [
	"def cari_jalan_sendiri():",
	"    keberanian = 0",
	"    harapan = True",
	"    while harapan:",
	"        keberanian += 1",
	"        if keberanian > batas_takut:",
	"            print('Aku memilih merdeka.')",
	"            break",
	"    return 'Selesai.'",
	"",
	"# Menjalankan program...",
	"cari_jalan_sendiri()  # Sukses dikompilasi!"
]

var current_line_idx: int = 0
var displayed_text: String = ""

func _ready() -> void:
	progress_bar.max_value = code_lines.size()
	progress_bar.value = 0
	code_label.text = "[color=#7a8299]// Ketuk layar untuk mengetik program koding...[/color]"
	type_button.pressed.connect(_on_type_pressed)

func _on_type_pressed() -> void:
	if current_line_idx < code_lines.size():
		AudioManager.play_keyboard_sfx()
		displayed_text += code_lines[current_line_idx] + "\n"
		code_label.text = "[color=#2a9d8f]" + displayed_text + "[/color]"
		current_line_idx += 1
		progress_bar.value = current_line_idx
		
		# Animasi tombol terpantul
		var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(type_button, "scale", Vector2(0.96, 0.96), 0.05)
		tw.tween_property(type_button, "scale", Vector2(1.0, 1.0), 0.08)
		
		if current_line_idx >= code_lines.size():
			type_button.text = "PROGRAM BERHASIL DIKOMPILASI!"
			type_button.disabled = true
			instruction_label.text = "Di layar laptop kusam ini, kamu merasa benar-benar hidup."
			var tw_end = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw_end.tween_interval(1.0)
			tw_end.tween_callback(func(): coding_completed.emit())
