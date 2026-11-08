class_name SaveSystem
extends RefCounted

## Sistema de Salvamento com Gravação Atômica (RNF-08, CA-16, Seção 12.5)
## Grava em arquivo temporário (.tmp) e substitui atomicamente para evitar corrupção de dados.

const SAVE_PATH: String = "user://savegame.json"
const SAVE_TEMP_PATH: String = "user://savegame.tmp"

var total_gold: int = 0
var candeeiro_upgrades: Dictionary = {
	"max_health": 0,    # +10 PV por nível
	"global_damage": 0, # +5% de dano por nível
	"gold_gain": 0,     # +10% de ouro por nível
	"luck": 0,          # +5% de sorte por nível
	"magnet_range": 0,  # +15% de raio de coleta por nível
	"extra_reroll": 0   # +1 reroll por nível
}

var grimoire_unlocked: Array[String] = ["galho_arruda"]
var unlocked_achievements: Array[String] = []

func _init() -> void:
	load_game()

## Grava os dados usando escrita atômica (RNF-08)
func save_game() -> bool:
	var data: Dictionary = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"total_gold": total_gold,
		"candeeiro_upgrades": candeeiro_upgrades,
		"grimoire_unlocked": grimoire_unlocked,
		"unlocked_achievements": unlocked_achievements
	}
	
	var json_string: String = JSON.stringify(data, "\t")
	
	# 1. Grava no arquivo temporário primeiro
	var file: FileAccess = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if not file:
		push_error("[SaveSystem] Falha ao abrir arquivo temporário para escrita.")
		return false
		
	file.store_string(json_string)
	file.close()
	
	# 2. Substituição atômica: remove save anterior e renomeia o temporário
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		
	var err: Error = DirAccess.rename_absolute(SAVE_TEMP_PATH, SAVE_PATH)
	if err != OK:
		push_error("[SaveSystem] Erro na substituição atômica: %d" % err)
		return false
		
	return true

## Carrega os dados persistidos no disco
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false # Save virgem
		
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
		
	var content: String = file.get_as_text()
	file.close()
	
	var test_json_conv: JSON = JSON.new()
	var parse_err: Error = test_json_conv.parse(content)
	if parse_err != OK:
		push_error("[SaveSystem] Arquivo de save corrompido.")
		return false
		
	var data: Dictionary = test_json_conv.data as Dictionary
	total_gold = int(data.get("total_gold", 0))
	
	if data.has("candeeiro_upgrades"):
		var saved_upgrades: Dictionary = data["candeeiro_upgrades"]
		for k in saved_upgrades:
			candeeiro_upgrades[k] = int(saved_upgrades[k])
			
	if data.has("grimoire_unlocked"):
		grimoire_unlocked.clear()
		for item in data["grimoire_unlocked"]:
			grimoire_unlocked.append(str(item))
			
	if data.has("unlocked_achievements"):
		unlocked_achievements.clear()
		for ach in data["unlocked_achievements"]:
			unlocked_achievements.append(str(ach))
			
	return true

## Adiciona ouro e salva atomicamente no disco (CA-12, CA-16)
func add_gold(amount: int) -> void:
	if amount > 0:
		total_gold += amount
		save_game()

## Desbloqueia uma entrada no Grimório (CA-08)
func unlock_grimoire_entry(entry_id: String) -> bool:
	if not grimoire_unlocked.has(entry_id):
		grimoire_unlocked.append(entry_id)
		save_game()
		return true
	return false

## Reseta o save para testes
func reset_save() -> void:
	total_gold = 0
	for k in candeeiro_upgrades:
		candeeiro_upgrades[k] = 0
	grimoire_unlocked = ["galho_arruda"]
	unlocked_achievements.clear()
	save_game()
