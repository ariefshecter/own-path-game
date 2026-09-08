extends Node

# Singleton untuk mengelola state antar-scene
var current_chapter: int = 1
var current_mini_chapter: int = 1
var current_floor: int = 1
var max_floors: int = 5

var player_name: String = "Rian"
var player_sanity: int = 50
var player_max_sanity: int = 50
var run_coins: int = 50
var permanent_savings: int = 0

# Status Hubungan Romansa (0: Mekar Indah, 1: Gesekan/Retak, 2: Kandas/Sendiri)
var romance_stage: int = 0

# Peta aktif mini chapter saat ini
var map_floors: Array = []
var current_node_id: String = ""

func reset_run() -> void:
	current_floor = 1
	player_sanity = player_max_sanity
	run_coins = 50
	current_node_id = ""

func hard_reset_entire_game() -> void:
	current_chapter = 1
	current_mini_chapter = 1
	current_floor = 1
	player_sanity = 50
	player_max_sanity = 50
	run_coins = 50
	permanent_savings = 0
	romance_stage = 0
	map_floors.clear()
	current_node_id = ""
	print("HARD RESET: Seluruh progres pemain dihapus karena menyerah pulang ke rumah.")

func deposit_to_bank(amount: int) -> bool:
	if amount <= 0 or run_coins < amount:
		return false
	run_coins -= amount
	permanent_savings += amount
	return true
