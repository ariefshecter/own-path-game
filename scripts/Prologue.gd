extends Control

@onready var speaker_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/SpeakerLabel
@onready var message_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/MessageLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/PortraitRect
@onready var next_btn: Button = $VBoxContainer/NextButton
@onready var skip_btn: Button = $VBoxContainer/SkipButton

const SPRITE_RIAN = preload("res://assets/sprites/protagonist_rian.png")
const SPRITE_FATHER = preload("res://assets/sprites/father.png")
const SPRITE_MOTHER = preload("res://assets/sprites/mother.png")
const SPRITE_DOSEN = preload("res://assets/sprites/dosen_pembimbing.png")

var current_step: int = 0
var dialogues: Array = []

func _ready() -> void:
	dialogues = [
		{
			"speaker": "Ruang Kamar Kos (Semester Akhir)",
			"portrait": null,
			"text": "Jam dinding berdetak di angka 02:15 dini hari. Di kamar kos yang pengap, draf skripsi Jurusan Pendidikan tergeletak di samping laptop tua yang terus mendengung."
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Sejak awal, aku tidak pernah ingin berada di jurusan ini. Aku selalu mencintai baris kode dan teknologi. Tapi demi tuntutan orang tua di kampung, aku menelan mimpiku sendiri."
		},
		{
			"speaker": "Dosen Pembimbing Skripsi",
			"portrait": SPRITE_DOSEN,
			"text": "\"Revisi lagi bab 4 kamu! Kenapa analisis datanya masih berantakan begini? Mau wisuda tahun ini atau mau nambah semester lagi?!\""
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Di sela-sela merevisi teori pendidikan yang asing di hatiku, aku mencuri waktu begadang belajar koding. Itu satu-satunya ruang di mana aku merasa memiliki kendali atas diriku sendiri."
		},
		{
			"speaker": "Hari Wisuda (Gedung Serbaguna)",
			"portrait": null,
			"text": "Bulan berganti. Kamu berhasil menyelesaikan semuanya tepat waktu. Di depan ribuan hadirin, namamu dipanggil sebagai Lulusan Terbaik Peringkat Kedua."
		},
		{
			"speaker": "Ayah",
			"portrait": SPRITE_FATHER,
			"text": "\"Peringkat kedua? Kenapa cuma nomor dua? Siapa yang nomor satu? Kenapa kamu selalu tidak pernah bisa jadi yang terbaik?!\""
		},
		{
			"speaker": "Ibu",
			"portrait": SPRITE_MOTHER,
			"text": "\"Iya le %s... Orang tua kan sudah banyak keluar biaya. Kalau cuma nomor dua, tetangga mana ada yang segan mendengarnya...\"" % GameState.player_name
		},
		{
			"speaker": "Ayah",
			"portrait": SPRITE_FATHER,
			"text": "\"Semua yang kamu makan, baju yang kamu pakai, sampai biaya kuliahmu itu dari mana? Jangan bertingkah seolah kamu sudah bisa menentukan arah hidupmu sendiri. Selama kamu masih bawa nama keluarga ini, kamu hanya perlu menjalankan apa yang sudah Papa siapkan.\""
		},
		{
			"speaker": "Sudut Meja Kamar Kos (Malam Itu)",
			"portrait": null,
			"text": "(Kamera menyorot sunyi ke atas meja kayu. Di samping map ijazah yang basah oleh air mata, berdiri sebuah botol kaca kecil tanpa label berisi cairan bening pekat...)"
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Kamu menatap botol kecil itu dalam keheningan yang dingin. Menyadari bahwa berapapun usiamu nanti, mereka tidak akan pernah membiarkanmu bernafas bebas. Tapi jauh di sudut hatimu yang sekarat, sebuah bisikan lirih muncul: 'Bagaimana jika... aku memilih pergi mencari jalanku sendiri?'"
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
		
		if d["portrait"] != null:
			portrait_rect.visible = true
			portrait_rect.texture = d["portrait"]
		else:
			portrait_rect.visible = false
		
		if current_step == dialogues.size() - 1:
			next_btn.text = "MENUTUP PINTU DAN MELANGKAH..."
		else:
			next_btn.text = "LANJUT (KETUK UNTUK MEMBACA)"
	else:
		_on_finish_prologue()

func _on_next_pressed() -> void:
	AudioManager.play_card_sfx()
	current_step += 1
	if current_step < dialogues.size():
		update_dialogue()
	else:
		_on_finish_prologue()

func _on_finish_prologue() -> void:
	AudioManager.play_coin_sfx()
	get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")
