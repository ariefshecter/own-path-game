extends Control

@onready var status_label: Label = $TopArea/StatusLabel
@onready var bank_slider: HSlider = $BankBox/HBoxContainer/BankSlider
@onready var deposit_amount_label: Label = $BankBox/HBoxContainer/DepositAmountLabel
@onready var deposit_btn: Button = $BankBox/DepositButton
@onready var heal_btn: Button = $ShopItemsBox/HealBox/HealButton
@onready var heal_info: Label = $ShopItemsBox/HealBox/HealInfo
@onready var buff_btn: Button = $ShopItemsBox/BuffBox/BuffButton
@onready var buff_info: Label = $ShopItemsBox/BuffBox/BuffInfo
@onready var leave_btn: Button = $BottomArea/LeaveButton
@onready var log_label: Label = $TopArea/LogLabel

var deposit_val: int = 0
const HEAL_COST = 30
const HEAL_AMOUNT = 20
const BUFF_COST = 45

var buff_purchased: bool = false

func _ready() -> void:
	update_ui()
	
	bank_slider.value_changed.connect(_on_slider_changed)
	deposit_btn.pressed.connect(_on_deposit_pressed)
	heal_btn.pressed.connect(_on_heal_pressed)
	buff_btn.pressed.connect(_on_buff_pressed)
	leave_btn.pressed.connect(_on_leave_pressed)

func update_ui() -> void:
	status_label.text = "Mental: %d/%d  |  Koin Run: %d  |  Tabungan Bank: %d" % [
		GameState.player_sanity,
		GameState.player_max_sanity,
		GameState.run_coins,
		GameState.permanent_savings
	]
	
	bank_slider.max_value = GameState.run_coins
	deposit_val = int(bank_slider.value)
	deposit_amount_label.text = "%d Koin" % deposit_val
	deposit_btn.disabled = (deposit_val <= 0 or GameState.run_coins <= 0)
	
	heal_info.text = "Pulihkan +%d Mental (Biaya: %d Koin)" % [HEAL_AMOUNT, HEAL_COST]
	heal_btn.disabled = (GameState.run_coins < HEAL_COST or GameState.player_sanity >= GameState.player_max_sanity)
	
	buff_info.text = "Minuman Energi (+1 Energi Awal Run Ini) (Biaya: %d Koin)" % BUFF_COST
	buff_btn.disabled = (GameState.run_coins < BUFF_COST or buff_purchased)
	if buff_purchased:
		buff_btn.text = "SUDAH DIBELI"

func _on_slider_changed(value: float) -> void:
	deposit_val = int(value)
	deposit_amount_label.text = "%d Koin" % deposit_val
	deposit_btn.disabled = (deposit_val <= 0)

func _on_deposit_pressed() -> void:
	if GameState.deposit_to_bank(deposit_val):
		log_label.text = "Berhasil menyetor %d Koin ke rekening tabungan abadi!" % deposit_val
		bank_slider.value = 0
		update_ui()

func _on_heal_pressed() -> void:
	if GameState.run_coins >= HEAL_COST:
		GameState.run_coins -= HEAL_COST
		GameState.player_sanity = min(GameState.player_max_sanity, GameState.player_sanity + HEAL_AMOUNT)
		log_label.text = "Makan nasi padang murah. Mental pulih +%d!" % HEAL_AMOUNT
		update_ui()

func _on_buff_pressed() -> void:
	if GameState.run_coins >= BUFF_COST and not buff_purchased:
		GameState.run_coins -= BUFF_COST
		buff_purchased = true
		log_label.text = "Membeli minuman energi! Stamina meningkat untuk lantai selanjutnya."
		update_ui()

func _on_leave_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")
