extends Node

# Singleton untuk mengelola state antar-scene & persistensi data lokal
const SAVE_PATH = "user://savegame.json"

var current_chapter: int = 1
var current_mini_chapter: int = 1
var current_floor: int = 1
var max_floors: int = 5

# Progres unlock tertinggi
var max_unlocked_mini_chapter: int = 1

var player_name: String = "Rian"
var player_sanity: int = 50
var player_max_sanity: int = 50
var run_coins: int = 50
var permanent_savings: int = 0

# Upgrade permanen yang sudah dibeli
var purchased_meta_upgrades: Array = []

# Status Hubungan Romansa (0: Mekar Indah, 1: Gesekan/Retak, 2: Kandas/Sendiri)
var romance_stage: int = 0

# Deck kartu aktif pemain
var default_starter_deck: Array = [
	"card_refuse", "card_refuse", "card_breathe", 
	"card_breathe", "card_indomie_nasi", "card_kucing_oren", "card_ignore_call"
]
var deck: Array = []

# Peta aktif mini chapter saat ini
var map_floors: Array = []
var current_node_id: String = ""

func _ready() -> void:
	if deck.is_empty():
		deck = default_starter_deck.duplicate()
	load_game()

func reset_run() -> void:
	current_floor = 1
	player_sanity = player_max_sanity
	run_coins = 50
	current_node_id = ""
	save_game()

func hard_reset_entire_game() -> void:
	current_chapter = 1
	current_mini_chapter = 1
	max_unlocked_mini_chapter = 1
	current_floor = 1
	player_sanity = 50
	player_max_sanity = 50
	run_coins = 50
	permanent_savings = 0
	purchased_meta_upgrades.clear()
	romance_stage = 0
	deck = default_starter_deck.duplicate()
	map_floors.clear()
	current_node_id = ""
	
	# Hapus file save di disk jika ada
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	print("HARD RESET: Seluruh progres pemain dihapus bersih dari disk dan memori.")

func deposit_to_bank(amount: int) -> bool:
	if amount <= 0 or run_coins < amount:
		return false
	run_coins -= amount
	permanent_savings += amount
	save_game()
	return true

func advance_mini_chapter() -> void:
	current_mini_chapter += 1
	if current_mini_chapter > max_unlocked_mini_chapter:
		max_unlocked_mini_chapter = current_mini_chapter
	current_floor = 1
	map_floors.clear()
	current_node_id = ""
	save_game()

func save_game() -> void:
	var save_dict = {
		"version": 1,
		"player_name": player_name,
		"current_chapter": current_chapter,
		"current_mini_chapter": current_mini_chapter,
		"max_unlocked_mini_chapter": max_unlocked_mini_chapter,
		"permanent_savings": permanent_savings,
		"purchased_meta_upgrades": purchased_meta_upgrades,
		"romance_stage": romance_stage,
		"deck": deck,
		"player_max_sanity": player_max_sanity
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		print("Progres berhasil disimpan ke: ", SAVE_PATH)
	else:
		printerr("Gagal menyimpan data game ke: ", SAVE_PATH)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Belum ada berkas simpanan lama. Memulai profil baru.")
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
		
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		player_name = parsed.get("player_name", "Rian")
		current_chapter = parsed.get("current_chapter", 1)
		current_mini_chapter = parsed.get("current_mini_chapter", 1)
		max_unlocked_mini_chapter = parsed.get("max_unlocked_mini_chapter", 1)
		permanent_savings = parsed.get("permanent_savings", 0)
		purchased_meta_upgrades = parsed.get("purchased_meta_upgrades", [])
		romance_stage = parsed.get("romance_stage", 0)
		player_max_sanity = parsed.get("player_max_sanity", 50)
		player_sanity = player_max_sanity
		
		var saved_deck = parsed.get("deck", [])
		if saved_deck is Array and not saved_deck.is_empty():
			deck = saved_deck
			
		print("Data berhasil dimuat! Nama: ", player_name, " | Mini Chapter: ", current_mini_chapter, " | Tabungan Bank: ", permanent_savings)
		return true
	return false

func has_saved_profile() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
