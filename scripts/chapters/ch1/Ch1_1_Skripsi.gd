extends Control

const SCRATCH_SCENE = preload("res://scenes/microgames/ScratchPaper.tscn")
const TYPING_SCENE = preload("res://scenes/microgames/TypingCoding.tscn")

const SPRITE_RIAN = preload("res://assets/sprites/protagonist_rian.png")
const SPRITE_DOSEN = preload("res://assets/sprites/dosen_pembimbing.png")

@onready var speaker_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/SpeakerLabel
@onready var message_label: Label = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/MessageLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/DialogueBox/MarginContainer/VBoxContainer/Header/PortraitRect
@onready var next_btn: Button = $VBoxContainer/NextButton
@onready var interaction_slot: Control = $InteractionSlot

var step: int = 0

func _ready() -> void:
	next_btn.pressed.connect(_on_next_pressed)
	show_step_0()

func show_step_0() -> void:
	step = 0
	portrait_rect.visible = true
	portrait_rect.texture = SPRITE_DOSEN
	speaker_label.text = "Dosen Pembimbing Skripsi"
	message_label.text = "\"Ini kamu baca lagi draf Bab 4 kamu! Metodologinya acak-acakan, korelasi datanya ngawur! Mau wisuda tepat waktu atau mau jadi mahasiswa abadi?! Coret dan rombak semuanya malam ini!\""
	next_btn.text = "TERIMA DRAF SKRIPSI TERCOROT"

func show_step_1_scratch_microgame() -> void:
	step = 1
	next_btn.visible = false
	speaker_label.text = "Draf Skripsi di Meja Kos"
	portrait_rect.visible = false
	message_label.text = "Coretan spidol merah dosen memenuhi setiap lembar kertas. Rian harus menelan rasa lelahnya dan mencoret ulang kalimat demi kalimat."
	
	var scratch_inst = SCRATCH_SCENE.instantiate()
	interaction_slot.add_child(scratch_inst)
	scratch_inst.scratching_completed.connect(func():
		scratch_inst.queue_free()
		show_step_2_coding_intro()
	)

func show_step_2_coding_intro() -> void:
	step = 2
	next_btn.visible = true
	portrait_rect.visible = true
	portrait_rect.texture = SPRITE_RIAN
	speaker_label.text = GameState.player_name
	message_label.text = "Jam 03:00 dini hari. Kepala berdenyut menatap revisi teori pendidikan yang membosankan. Tanganku refleks membuka terminal laptop... Ini satu-satunya hal yang membuat nafasku terasa nyata."
	next_btn.text = "BUKA EDITOR KODE RAHASIA"

func show_step_3_typing_microgame() -> void:
	step = 3
	next_btn.visible = false
	speaker_label.text = "Laptop Kusam di Sudut Kamar"
	portrait_rect.visible = false
	message_label.text = "Di sela-sela tumpukan draf skripsi yang dibencinya, Rian mengetik baris kode pertamanya malam ini."
	
	var typing_inst = TYPING_SCENE.instantiate()
	interaction_slot.add_child(typing_inst)
	typing_inst.coding_completed.connect(func():
		typing_inst.queue_free()
		show_step_4_outro()
	)

func show_step_4_outro() -> void:
	step = 4
	next_btn.visible = true
	portrait_rect.visible = true
	portrait_rect.texture = SPRITE_RIAN
	speaker_label.text = GameState.player_name
	message_label.text = "Layar laptop menampilkan 'Build Succeeded'. Sebuah senyuman kecil terbit di wajahku yang pucat. Bab 4 selesai dicoret, dan sebaris mimpiku tetap menyala... meski esok hari tuntutan baru sudah menunggu."
	next_btn.text = "SELESAIKAN MINI CHAPTER 1.1"

func _on_next_pressed() -> void:
	AudioManager.play_card_sfx()
	if step == 0:
		show_step_1_scratch_microgame()
	elif step == 2:
		show_step_3_typing_microgame()
	elif step == 4:
		# Selesai Mini Chapter 1.1 -> Simpan progres & kembali ke Hub Kamar Kos
		GameState.advance_mini_chapter()
		get_tree().change_scene_to_file("res://scenes/HubScreen.tscn")
