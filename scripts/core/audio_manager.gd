class_name AudioManager
extends Node

## Gerenciador Central de Áudio e Sintetizador Procedural (Seção 10.4)
## Sintetiza proceduralmente em PCM 16-bit todos os efeitos sonoros do jogo em tempo real,
## garantindo áudio nativo e responsivo sem dependência de arquivos externos,
## com modulação procedural de pitch (0.94 a 1.06) para evitar fadiga auditiva.

@export var master_volume: float = 1.0 # 0.0 a 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 1.0

var sfx_players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 16

# Efeitos sonoros sintetizados
var sfx_gem: AudioStreamWAV = null
var sfx_hit: AudioStreamWAV = null
var sfx_death: AudioStreamWAV = null
var sfx_fanfare: AudioStreamWAV = null
var sfx_gun: AudioStreamWAV = null
var sfx_slash: AudioStreamWAV = null

func _ready() -> void:
	add_to_group("audio")
	_setup_audio_pool()
	_synthesize_all_sfx()
	
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

## Toca um efeito sonoro com pitch shift leve procedural (Seção 10.4)
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

# --- Sintetizador Procedural de Áudio 16-Bit ---

func _synthesize_all_sfx() -> void:
	sfx_gem = _generate_tone(520.0, 1080.0, 0.12, false, 0.8)
	sfx_hit = _generate_tone(180.0, 45.0, 0.09, true, 0.9)
	sfx_death = _generate_tone(320.0, 70.0, 0.14, true, 0.75)
	sfx_fanfare = _generate_fanfare(0.38)
	sfx_gun = _generate_tone(900.0, 120.0, 0.11, true, 1.0)
	sfx_slash = _generate_tone(450.0, 150.0, 0.13, true, 0.7)

func _generate_tone(freq_start: float, freq_end: float, duration: float, is_noise_mixed: bool, vol_mult: float, sample_rate: int = 22050) -> AudioStreamWAV:
	var total_samples: int = int(duration * float(sample_rate))
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerpf(freq_start, freq_end, t)
		phase += (freq * TAU) / float(sample_rate)
		
		var envelope: float = (1.0 - t) * (1.0 - t)
		var sine_val: float = sin(phase)
		var sample_val: float
		if is_noise_mixed:
			var noise: float = randf_range(-1.0, 1.0)
			sample_val = ((sine_val * 0.4) + (noise * 0.6)) * envelope * vol_mult
		else:
			sample_val = sine_val * envelope * vol_mult
			
		var int16_val: int = int(clampf(sample_val * 32767.0, -32768.0, 32767.0))
		if int16_val < 0:
			int16_val += 65536
		data[i * 2] = int16_val & 0xFF
		data[i * 2 + 1] = (int16_val >> 8) & 0xFF
		
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_fanfare(duration: float, sample_rate: int = 22050) -> AudioStreamWAV:
	var total_samples: int = int(duration * float(sample_rate))
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples * 2)
	
	# Arpejo Dó-Mi-Sol-Dó
	var notes: Array[float] = [261.63, 329.63, 392.0, 523.25]
	var phase: float = 0.0
	
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var note_idx: int = mini(int(t * float(notes.size())), notes.size() - 1)
		var freq: float = notes[note_idx]
		phase += (freq * TAU) / float(sample_rate)
		
		var env: float = (1.0 - (t * 0.7))
		var s: float = sin(phase) * env * 0.85
		var int16_val: int = int(clampf(s * 32767.0, -32768.0, 32767.0))
		if int16_val < 0:
			int16_val += 65536
		data[i * 2] = int16_val & 0xFF
		data[i * 2 + 1] = (int16_val >> 8) & 0xFF
		
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# --- Gatilhos Públicos de Efeitos Sonoros ---

func play_sfx_gem() -> void:
	play_sfx_pitch(sfx_gem, 1.0)

func play_sfx_hit() -> void:
	play_sfx_pitch(sfx_hit, 1.0)

func play_sfx_death() -> void:
	play_sfx_pitch(sfx_death, 1.0)

func play_sfx_fanfare() -> void:
	play_sfx_pitch(sfx_fanfare, 1.0)

func play_sfx_gun() -> void:
	play_sfx_pitch(sfx_gun, 1.0)

func play_sfx_slash() -> void:
	play_sfx_pitch(sfx_slash, 1.0)
