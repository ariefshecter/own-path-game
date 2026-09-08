extends Control

@onready var speaker_label: Label = $VBoxContainer/DialogueBox/SpeakerLabel
@onready var message_label: Label = $VBoxContainer/DialogueBox/MessageLabel
@onready var next_btn: Button = $VBoxContainer/NextButton
@onready var skip_btn: Button = $VBoxContainer/SkipButton

var current_step: int = 0
var dialogues: Array = []

func _ready() -> void:
	dialogues = [
		{
			"speaker": "Suasana Meja Makan",
			"text": "Malam itu hening. Hanya ada suara denting sendok beradu dengan piring kaca dan suara kipas angin berderit lambat di ruang tengah rumah keluarga."
		},
		{
			"speaker": "Ayah",
			"text": "\"Bulan depan kamu harus ikut seleksi instansi yang sudah Papa siapkan. Formulirnya sudah Papa isi, kenalan Papa tinggal tanda tangan. Jangan bikin rumit hal mudah.\""
		},
		{
			"speaker": "Ibu",
			"text": "\"Iya le %s... Orang tua itu cuma mau kamu aman. Zaman sekarang cari kerja susah. Mau jadi apa kalau cuma ngejar hobi dan idealisme kosong?\"" % GameState.player_name
		},
		{
			"speaker": GameState.player_name,
			"text": "\"Tapi Ma, Pa... itu bukan jalan yang aku mau. Aku ingin mencoba sesuatu yang kupilih sendiri, walau harus mulai dari nol.\""
		},
		{
			"speaker": "Ayah",
			"text": "(Meletakkan sendok dengan keras) \"Coba sendiri? Dengan modal apa?! Kamu pikir hidup mandiri itu segampang cerita di buku-buku?! Kalau kamu melangkah keluar dari pintu depan, jangan pernah pulang sambil merengek minta tolong!\""
		},
		{
			"speaker": "Ibu",
			"text": "\"Sudahlah %s, minta maaf sama Papamu. Jangan buat malu keluarga besar. Dengarkan orang tua...\"" % GameState.player_name
		},
		{
			"speaker": GameState.player_name,
			"text": "Kamu terdiam. Menunduk menatap piring nasi yang baru separuh habis. Kamu sadar, jika malam ini kamu tidak melangkah keluar... kamu tidak akan pernah punya kesempatan untuk hidup atas pilihanmu sendiri."
		},
		{
			"speaker": "Pintu Depan Rumah",
			"text": "Tengah malam. Ransel lusuh sudah di pundakmu. Udara dingin menyambut saat gerbang pagar besi berderit pelan. Langkah pertamamu dimulai sekarang."
		}
	]
	
	next_btn.pressed.connect(_on_next_pressed)
	skip_btn.pressed.connect(_on_finish_prologue)
	update_dialogue()

func update_dialogue() -> void:
	if current_step < dialogues.size():
		var d = dialogues[current_step]
		speaker_label.text = d["speaker"]
		message_label.text = d["text"]
		
		if current_step == dialogues.size() - 1:
			next_btn.text = "MELANGKAH KE JALAN SENDIRI"
		else:
			next_btn.text = "LANJUT (KETUK UNTUK MEMBACA)"
	else:
		_on_finish_prologue()

func _on_next_pressed() -> void:
	current_step += 1
	if current_step < dialogues.size():
		update_dialogue()
	else:
		_on_finish_prologue()

func _on_finish_prologue() -> void:
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")
