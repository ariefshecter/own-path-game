extends Node

# Singleton Pengelola Audio & Efek Suara
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var sfx_card: AudioStream
var sfx_coin: AudioStream
var sfx_hit: AudioStream
var sfx_shield: AudioStream
var bgm_stream: AudioStream

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	bgm_player.volume_db = -8.0
	add_child(bgm_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	sfx_player.volume_db = -4.0
	add_child(sfx_player)
	
	load_audio_resources()
	play_bgm()

func load_audio_resources() -> void:
	if ResourceLoader.exists("res://assets/audio/card_play.wav"):
		sfx_card = load("res://assets/audio/card_play.wav")
	if ResourceLoader.exists("res://assets/audio/coin.wav"):
		sfx_coin = load("res://assets/audio/coin.wav")
	if ResourceLoader.exists("res://assets/audio/hit.wav"):
		sfx_hit = load("res://assets/audio/hit.wav")
	if ResourceLoader.exists("res://assets/audio/shield.wav"):
		sfx_shield = load("res://assets/audio/shield.wav")
	if ResourceLoader.exists("res://assets/audio/bgm_warm_loop.wav"):
		bgm_stream = load("res://assets/audio/bgm_warm_loop.wav")

func play_bgm() -> void:
	if bgm_stream and not bgm_player.playing:
		bgm_player.stream = bgm_stream
		bgm_player.play()
		bgm_player.finished.connect(func(): bgm_player.play())

func play_card_sfx() -> void:
	if sfx_card:
		sfx_player.stream = sfx_card
		sfx_player.pitch_scale = randf_range(0.95, 1.05)
		sfx_player.play()

func play_coin_sfx() -> void:
	if sfx_coin:
		sfx_player.stream = sfx_coin
		sfx_player.pitch_scale = randf_range(0.98, 1.02)
		sfx_player.play()

func play_hit_sfx() -> void:
	if sfx_hit:
		sfx_player.stream = sfx_hit
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.play()

func play_shield_sfx() -> void:
	if sfx_shield:
		sfx_player.stream = sfx_shield
		sfx_player.pitch_scale = randf_range(0.95, 1.05)
		sfx_player.play()
