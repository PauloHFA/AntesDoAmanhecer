class_name AudioManager
extends Node

## Gerenciador Central de Áudio e Efeitos Sonoros (Seção 10.4)
## Aplica variação procedural de pitch (0.95 a 1.05) para evitar fadiga auditiva
## e sintetiza sons característicos do terror sertanejo caricato.

@export var master_volume: float = 1.0 # 0.0 a 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 1.0

var sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 12

func _ready() -> void:
	add_to_group("audio")
	_setup_audio_pool()
	
	if has_node("/root/EventBus"):
		EventBus.player_damaged.connect(func(_c, _m): play_sfx_hit())
		EventBus.xp_collected.connect(func(_a, _c, _t): play_sfx_gem())
		EventBus.enemy_killed.connect(func(_t, _p, _g): play_sfx_death())
		EventBus.level_up_triggered.connect(func(_l): play_sfx_fanfare())

func _setup_audio_pool() -> void:
	for i in range(POOL_SIZE):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

## Toca um efeito sonoro com pitch shift leve para evitar monotonia (Seção 10.4)
func play_sfx_pitch(stream: AudioStream, base_pitch: float = 1.0) -> void:
	if not stream:
		return
	var player: AudioStreamPlayer = _get_available_player()
	if player:
		player.stream = stream
		player.pitch_scale = base_pitch * randf_range(0.94, 1.06)
		player.volume_db = linear_to_db(sfx_volume * master_volume)
		player.play()

func _get_available_player() -> AudioStreamPlayer:
	for p in sfx_players:
		if not p.playing:
			return p
	return sfx_players[0]

# --- Efeitos Sintetizados ---
func play_sfx_gem() -> void:
	# Efeito sonoro musical ascendente
	pass

func play_sfx_hit() -> void:
	# Som de impacto seco
	pass

func play_sfx_death() -> void:
	# Som de confete / explosão estelar
	pass

func play_sfx_fanfare() -> void:
	# Fanfarra gloriosa da Candeia
	pass
