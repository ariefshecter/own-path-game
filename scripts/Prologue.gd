extends Control

@onready var speaker_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/SpeakerLabel
@onready var message_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/MessageLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/PortraitRect
@onready var next_btn: Button = $VBoxContainer/NextButton
@onready var skip_btn: Button = $VBoxContainer/SkipButton
@onready var scene_bg: TextureRect = $Background

const SPRITE_RIAN = preload("res://assets/sprites/protagonist_rian.png")
const SPRITE_FATHER = preload("res://assets/sprites/father.png")
const SPRITE_MOTHER = preload("res://assets/sprites/mother.png")
const SPRITE_DOSEN = preload("res://assets/sprites/dosen_pembimbing.png")

var current_step: int = 0
var dialogues: Array = []

func _ready() -> void:
	dialogues = [
		{
			"speaker": "Ruang Kamar Kos (Semester 8)",
			"portrait": null,
			"text": "Malam itu jam menunjukkan pukul 02:14 dini hari. Di kamar kos berantakan, tumpukan draf skripsi Jurusan Pendidikan tergeletak berserakan dengan coretan spidol merah."
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Sejak awal, aku tidak pernah ingin berada di jurusan ini. Aku selalu mencintai dunia baris kode dan teknologi. Tapi demi senyum orang tua di kampung, aku menuruti pilihan mereka."
		},
		{
			"speaker": "Dosen Pembimbing Skripsi",
			"portrait": SPRITE_DOSEN,
			"text": "\"Revisi lagi bab 4 kamu! Kenapa analisis datanya masih kacau begini? Mau lulus tahun ini atau nambah semester lagi?!\""
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Di sela-sela lelahnya merevisi teori pendidikan yang tidak kucintai, aku mencuri waktu begadang belajar koding otodidak. Itu satu-satunya pelarian yang membuatku merasa hidup."
		},
		{
			"speaker": "Hari Wisuda (Gedung Serbaguna)",
			"portrait": null,
			"text": "Beberapa bulan kemudian. Kamu berhasil lulus tepat waktu. Di panggung megah, namamu diumumkan sebagai Lulusan Terbaik Peringkat Kedua di fakultas."
		},
		{
			"speaker": "Ayah",
			"portrait": SPRITE_FATHER,
			"text": "\"Peringkat kedua? Kenapa bukan yang pertama? Siapa yang nomor satu itu? Kenapa kamu selalu tanggung kalau berbuat sesuatu?!\""
		},
		{
			"speaker": "Ibu",
			"portrait": SPRITE_MOTHER,
			"text": "\"Iya le %s... Orang tua kan sudah banyak keluar biaya. Kalau cuma nomor dua, tetangga mana ada yang bangga dengarnya...\"" % GameState.player_name
		},
		{
			"speaker": GameState.player_name,
			"portrait": SPRITE_RIAN,
			"text": "Dada terasa sesak. Tepuk tangan ribuan orang di aula wisuda terdengar seperti dengung kosong. Apapun yang kukorbankan, seberapa keras pun aku memeras keringat... itu tidak akan pernah cukup."
		},
		{
			"speaker": "Malam Penentuan",
			"portrait": SPRITE_RIAN,
			"text": "Di kamar kos yang dingin, memegang lembar ijazah yang terasa hampa, kamu mengambil ranselmu. Keputusan telah bulat: Kamu harus keluar dan mencari jalan hidupmu sendiri."
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
			next_btn.text = "MULAI EKSPEDISI MINI CHAPTER 1.1"
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
