extends PanelContainer

signal scratching_completed

@onready var scratch_button: Button = $MarginContainer/VBoxContainer/ScratchButton
@onready var draft_label: RichTextLabel = $MarginContainer/VBoxContainer/PaperBox/DraftLabel
@onready var counter_label: Label = $MarginContainer/VBoxContainer/CounterLabel

var scratches_done: int = 0
const MAX_SCRATCHES = 4

var paragraphs: Array = [
	"Pendekatan pembelajaran konvensional ini [color=#d62828][strike]TIDAK RELEVAN DENGAN TEORI BAB 2![/strike][/color]",
	"Metodologi pengumpulan angket kuantitatif [color=#d62828][strike]DATA SAMPEL KURANG VALID, CORET SEMUA![/strike][/color]",
	"Analisis korelasi hipotesis [color=#d62828][strike]SALAH RUMUS! TULIS ULANG BAB INI DARI AWAL![/strike][/color]",
	"Kesimpulan skripsi [color=#d62828][strike]TIDAK MENJAWAB RUMUSAN MASALAH! BONGKAR LAGI![/strike][/color]"
]

func _ready() -> void:
	update_text()
	scratch_button.pressed.connect(_on_scratch_pressed)

func update_text() -> void:
	var full = ""
	for i in range(paragraphs.size()):
		if i < scratches_done:
			full += "• " + paragraphs[i] + "\n\n"
		else:
			full += "• " + paragraphs[i].replace("[strike]", "").replace("[/strike]", "").replace("[color=#d62828]", "[color=#333333]") + "\n\n"
	draft_label.text = full
	counter_label.text = "Coretan Dosen Terselesaikan: %d / %d" % [scratches_done, MAX_SCRATCHES]

func _on_scratch_pressed() -> void:
	if scratches_done < MAX_SCRATCHES:
		AudioManager.play_card_sfx()
		scratches_done += 1
		update_text()
		
		var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(scratch_button, "scale", Vector2(0.95, 0.95), 0.06)
		tw.tween_property(scratch_button, "scale", Vector2(1.0, 1.0), 0.08)
		
		if scratches_done >= MAX_SCRATCHES:
			scratch_button.text = "SEMUA CORETAN TELAH DITELAN..."
			scratch_button.disabled = true
			var tw_end = create_tween()
			tw_end.tween_interval(0.8)
			tw_end.tween_callback(func(): scratching_completed.emit())
