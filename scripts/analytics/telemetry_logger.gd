class_name TelemetryLogger
extends RefCounted

## Coletor de Telemetria e Métricas de Partida (Seção 15, RF-18, CA-12)
## Registra métricas de desempenho, escolhas de poderes, mortes e DPS de armas para balanceamento.

const TELEMETRY_FILE_PATH: String = "user://telemetry_sessions.json"

static func create_empty_session_record(character_name: String = "Benzedeira") -> Dictionary:
	return {
		"session_id": "sess_%d" % Time.get_unix_time_from_system(),
		"character": character_name,
		"stage": "vila_candeia",
		"duration_seconds": 0.0,
		"final_level": 1,
		"kills": 0,
		"gold_collected": 0,
		"weapons_equipped": {},
		"passives_equipped": {},
		"death_cause": "em_andamento",
		"fps_drops_count": 0,
		"damage_dealt_by_weapon": {},
		"completed_dawn": false
	}

## Registra término de partida e salva registro em disco
static func log_match_end(data: Dictionary) -> void:
	var sessions: Array = load_saved_sessions()
	sessions.append(data)
	
	# Salva de forma limpa no formato JSON
	var file := FileAccess.open(TELEMETRY_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_str: String = JSON.stringify(sessions, "\t")
		file.store_string(json_str)
		file.close()

## Carrega histórico de telemetria salvo
static func load_saved_sessions() -> Array:
	if not FileAccess.file_exists(TELEMETRY_FILE_PATH):
		return []
		
	var file := FileAccess.open(TELEMETRY_FILE_PATH, FileAccess.READ)
	if not file:
		return []
		
	var content: String = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		return parsed
	return []

## Análise agregada de balanceamento (Seção 15: armas quebradas ou fracas)
static func analyze_weapon_balance(sessions: Array) -> Dictionary:
	var weapon_damage_totals: Dictionary = {}
	var weapon_use_counts: Dictionary = {}
	var total_matches: int = sessions.size()
	var total_wins: int = 0
	
	for s in sessions:
		if s.get("completed_dawn", false):
			total_wins += 1
			
		var dmg_dict: Dictionary = s.get("damage_dealt_by_weapon", {})
		for weapon_id in dmg_dict:
			var dmg: float = float(dmg_dict[weapon_id])
			weapon_damage_totals[weapon_id] = weapon_damage_totals.get(weapon_id, 0.0) + dmg
			weapon_use_counts[weapon_id] = weapon_use_counts.get(weapon_id, 0) + 1
			
	var weapon_average_dps: Dictionary = {}
	for weapon_id in weapon_damage_totals:
		var uses: int = weapon_use_counts[weapon_id]
		weapon_average_dps[weapon_id] = weapon_damage_totals[weapon_id] / maxf(1.0, float(uses))
		
	var win_rate: float = (float(total_wins) / float(total_matches) * 100.0) if total_matches > 0 else 0.0
	
	return {
		"total_matches": total_matches,
		"win_rate": win_rate,
		"weapon_use_counts": weapon_use_counts,
		"weapon_average_damage": weapon_average_dps
	}
