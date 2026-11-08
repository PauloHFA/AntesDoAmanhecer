class_name HeadlessAutoplayBot
extends RefCounted

## Bot de Autojogo Headless e Simulador de Partidas (Seção 15, RF-18, CA-14)
## Simula partidas completas de 20 minutos (1.200 segundos) de forma ultra-acelerada
## para avaliar balanceamento de armas, curvas de sobrevivência e identificar armas fracas ou quebradas.

enum AIStrategy {
	SYNERGY,    # Foca em armas compatíveis e busca evoluções (Seção 7.1)
	BALANCED,   # Distribui igualmente entre armas e passivas de defesa
	SPECIALIST, # Foca em maximizar uma única arma antes das outras
	RANDOM      # Escolhas aleatórias para simular jogadores novatos
}

const WEAPON_BASE_DPS: Dictionary = {
	"galho_arruda": 18.0,
	"garrucha": 22.0,
	"fogo_fatuo": 20.0,
	"facao": 24.0,
	"sino": 16.0,
	# Evoluções
	"coroa_arruda": 55.0,
	"trovao_sertao": 65.0,
	"boitata": 70.0,
	"facao_furioso": 62.0,
	"repique_final": 58.0,
	# Fusões Secretas
	"aurora_rubra": 140.0,
	"tempestade_sertao": 135.0,
	"bencao_total": 125.0
}

const PASSIVE_POOL: Array[String] = [
	"escapulario",    # Armadura / redução de dano
	"chapeu_de_couro", # Vida máxima adicional
	"ferradura",       # Velocidade de movimento
	"garrafada"        # Regeneração de vida
]

## Executa uma simulação headless de partida completa
static func simulate_match(
	character_id: String = "benzedeira",
	strategy: AIStrategy = AIStrategy.SYNERGY,
	max_sim_seconds: float = 1200.0,
	tick_step: float = 1.0,
	run_seed: int = 12345
) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed
	
	# Atributos iniciais do Vigilante
	var max_hp: float = 100.0
	var current_hp: float = 100.0
	var speed: float = 120.0
	var armor_pct: float = 0.0
	var regen_per_sec: float = 0.0
	
	# Modificadores de classe
	var initial_weapon: String = "galho_arruda"
	match character_id:
		"benzedeira":
			initial_weapon = "galho_arruda"
			regen_per_sec += 0.2 # 1 PV a cada 5s
		"cangaceiro":
			initial_weapon = "garrucha"
			speed = 135.0
		"ferreiro":
			initial_weapon = "facao"
			max_hp = 140.0
			current_hp = 140.0
			armor_pct = 0.15
		"capoeirista":
			initial_weapon = "facao"
			speed = 145.0
		"violeiro":
			initial_weapon = "sino"
		"coveiro":
			initial_weapon = "fogo_fatuo"
			max_hp = 120.0
			current_hp = 120.0
			
	var equipped_weapons: Dictionary = { initial_weapon: 1 } # weapon_id -> level (1 a 5)
	var equipped_passives: Dictionary = {} # passive_id -> level (1 a 5)
	var damage_dealt_by_weapon: Dictionary = { initial_weapon: 0.0 }
	
	var elapsed_time: float = 0.0
	var current_level: int = 1
	var current_xp: float = 0.0
	var kills_total: int = 0
	var gold_total: int = 0
	var chest_timer: float = 0.0
	var death_cause: String = "sobreviveu"
	var completed_dawn: bool = false
	
	while elapsed_time < max_sim_seconds and current_hp > 0.0:
		var current_minute: float = elapsed_time / 60.0
		
		# 1. Escalonamento da horda pelo GDD (Seção 8.2)
		var hp_scaling: float = 1.0 + (0.08 * current_minute) + (0.003 * current_minute * current_minute)
		var horde_threat: float = (15.0 + (current_minute * 12.0) + (current_minute * current_minute * 0.4))
		
		# 2. Cálculo do DPS do Jogador
		var total_player_dps: float = 0.0
		for w_id in equipped_weapons:
			var w_lvl: int = equipped_weapons[w_id]
			var base_dps: float = WEAPON_BASE_DPS.get(w_id, 20.0)
			# Níveis concedem +25% de dano por nível
			var weapon_dps: float = base_dps * (1.0 + (w_lvl - 1) * 0.25)
			var tick_damage: float = weapon_dps * tick_step
			
			damage_dealt_by_weapon[w_id] = damage_dealt_by_weapon.get(w_id, 0.0) + tick_damage
			total_player_dps += weapon_dps
			
		# 3. Pressão da Horda e Dano no Vigilante
		# Evasão proporcional à velocidade do jogador (kiting)
		var evasion: float = clampf((speed - 60.0) / 160.0, 0.15, 0.65)
		
		# Se o DPS do jogador superar a ameaça, ele mata os monstros e sofre pouco dano
		var threat_deficit: float = horde_threat - (total_player_dps * 0.45)
		if threat_deficit > 0.0:
			var incoming_dmg: float = threat_deficit * (1.0 - armor_pct) * (1.0 - evasion) * tick_step
			current_hp -= incoming_dmg
			
		# Regeneração de vida
		if regen_per_sec > 0.0:
			current_hp = minf(max_hp, current_hp + (regen_per_sec * tick_step))
			
		# 4. Abates e Ganho de XP
		var kills_this_tick: int = int(round((total_player_dps * tick_step) / (18.0 * hp_scaling)))
		kills_this_tick = maxi(1, kills_this_tick)
		kills_total += kills_this_tick
		
		# Ouro: 8% de chance por abate (Seção 9.1)
		var gold_gained: int = int(kills_this_tick * 0.08)
		gold_total += gold_gained
		
		# XP por abate
		var xp_gain: float = kills_this_tick * 1.5
		current_xp += xp_gain
		
		# 5. Sistema de Level Up
		var xp_needed: float = round(10.0 + (6.0 * current_level) + (0.35 * current_level * current_level))
		while current_xp >= xp_needed:
			current_xp -= xp_needed
			current_level += 1
			_apply_level_up_choice(strategy, equipped_weapons, equipped_passives, rng)
			
			# Recalcula atributos passivos
			armor_pct = equipped_passives.get("escapulario", 0) * 0.08
			max_hp = 100.0 + (equipped_passives.get("chapeu_de_couro", 0) * 25.0)
			speed = 120.0 + (equipped_passives.get("ferradura", 0) * 15.0)
			regen_per_sec = (equipped_passives.get("garrafada", 0) * 0.35)
			
			xp_needed = round(10.0 + (6.0 * current_level) + (0.35 * current_level * current_level))
			
		# 6. Baús Periódicos e Evoluções (Minuto 3, 7, 10, 14, 18)
		chest_timer += tick_step
		if chest_timer >= 180.0: # A cada 3 minutos
			chest_timer = 0.0
			_evaluate_chest_evolution(equipped_weapons, equipped_passives)
			
		# 7. Desafios de Chefes (Minuto 10: Mapinguari, Minuto 18: Cuca)
		if int(elapsed_time) == 600: # 10:00
			var required_boss_dps: float = 70.0
			if total_player_dps < required_boss_dps:
				# Dano pesado caso o DPS seja baixo
				current_hp -= 55.0
				if current_hp <= 0.0:
					death_cause = "Chefe Mapinguari (DPS insuficiente no minuto 10)"
		elif int(elapsed_time) == 1080: # 18:00
			var required_boss_dps: float = 130.0
			if total_player_dps < required_boss_dps:
				current_hp -= 90.0
				if current_hp <= 0.0:
					death_cause = "Chefe Cuca (DPS insuficiente no minuto 18)"
					
		# Checa se morreu por horda
		if current_hp <= 0.0 and death_cause == "sobreviveu":
			death_cause = "Sobrepujado pela Horda no minuto %.1f" % current_minute
			break
			
		elapsed_time += tick_step
		
	if current_hp > 0.0 and elapsed_time >= max_sim_seconds:
		completed_dawn = true
		death_cause = "Amanhecer Alcançado (Vitória CA-11)"
		
	# Calcula métricas de balanceamento
	var total_damage: float = 0.0
	for w in damage_dealt_by_weapon:
		total_damage += damage_dealt_by_weapon[w]
		
	var weapon_dps_stats: Dictionary = {}
	var underpowered_weapons: Array[String] = []
	var overpowered_weapons: Array[String] = []
	
	for w in damage_dealt_by_weapon:
		var dmg: float = damage_dealt_by_weapon[w]
		var pct: float = (dmg / maxf(1.0, total_damage)) * 100.0
		var avg_dps: float = dmg / maxf(1.0, elapsed_time)
		weapon_dps_stats[w] = {
			"total_damage": dmg,
			"pct_of_total": pct,
			"avg_dps": avg_dps
		}
		# Regras de balanceamento (Seção 15)
		if equipped_weapons.get(w, 0) >= 3 and pct < 12.0 and elapsed_time > 300.0:
			underpowered_weapons.append(w)
		elif pct > 70.0 and equipped_weapons.size() >= 3:
			overpowered_weapons.append(w)
			
	return {
		"character": character_id,
		"strategy": strategy,
		"elapsed_time": elapsed_time,
		"completed_dawn": completed_dawn,
		"death_cause": death_cause,
		"final_level": current_level,
		"kills_total": kills_total,
		"gold_total": gold_total,
		"weapons": equipped_weapons,
		"passives": equipped_passives,
		"weapon_stats": weapon_dps_stats,
		"underpowered_weapons": underpowered_weapons,
		"overpowered_weapons": overpowered_weapons
	}

## Executa um lote de N simulações para obter estatísticas consolidadas
static func simulate_batch(
	character_id: String = "benzedeira",
	strategy: AIStrategy = AIStrategy.SYNERGY,
	runs_count: int = 10
) -> Dictionary:
	var total_victories: int = 0
	var total_time: float = 0.0
	var total_kills: int = 0
	var death_causes_tally: Dictionary = {}
	var weapon_aggregate_dps: Dictionary = {}
	var runs_data: Array[Dictionary] = []
	
	for i in range(runs_count):
		var res: Dictionary = simulate_match(character_id, strategy, 1200.0, 1.0, 1000 + i * 37)
		runs_data.append(res)
		
		if res["completed_dawn"]:
			total_victories += 1
		total_time += res["elapsed_time"]
		total_kills += res["kills_total"]
		
		var cause: String = res["death_cause"]
		death_causes_tally[cause] = death_causes_tally.get(cause, 0) + 1
		
		var w_stats: Dictionary = res["weapon_stats"]
		for w in w_stats:
			weapon_aggregate_dps[w] = weapon_aggregate_dps.get(w, 0.0) + w_stats[w]["avg_dps"]
			
	for w in weapon_aggregate_dps:
		weapon_aggregate_dps[w] = weapon_aggregate_dps[w] / float(runs_count)
		
	var win_rate: float = (float(total_victories) / float(runs_count)) * 100.0
	var avg_survival_time: float = total_time / float(runs_count)
	
	return {
		"runs_count": runs_count,
		"win_rate_pct": win_rate,
		"avg_survival_time_sec": avg_survival_time,
		"avg_kills": float(total_kills) / float(runs_count),
		"death_causes": death_causes_tally,
		"weapon_average_dps": weapon_aggregate_dps,
		"sample_runs": runs_data
	}

## Lógica de escolha de cartas de level up pela IA do Bot
static func _apply_level_up_choice(
	strategy: AIStrategy,
	weapons: Dictionary,
	passives: Dictionary,
	rng: RandomNumberGenerator
) -> void:
	# Armas disponíveis para pegar se houver slot livre (< 4 armas)
	var available_weapons: Array[String] = ["galho_arruda", "garrucha", "fogo_fatuo", "facao", "sino"]
	
	match strategy:
		AIStrategy.SYNERGY:
			# Tenta pegar a passiva que combina com as armas equipadas
			for w_id in weapons:
				if WeaponEvolutionManager.EVOLUTION_RECIPES.has(w_id):
					var req_pass: String = WeaponEvolutionManager.EVOLUTION_RECIPES[w_id]["required_passive"]
					if not passives.has(req_pass) and passives.size() < 4:
						passives[req_pass] = 1
						return
						
			# Se já tem as passivas necessárias, upa as armas principais
			for w_id in weapons:
				if weapons[w_id] < 5:
					weapons[w_id] += 1
					return
					
			# Se sobrou slot de arma, adiciona uma nova
			if weapons.size() < 4:
				for w in available_weapons:
					if not weapons.has(w):
						weapons[w] = 1
						return
						
			# Senão upa passivas restantes
			for p in PASSIVE_POOL:
				if passives.get(p, 0) < 5:
					passives[p] = passives.get(p, 0) + 1
					return
					
		AIStrategy.SPECIALIST:
			# Foca primeiro em levar a arma inicial ao máximo
			for w in weapons:
				if weapons[w] < 5:
					weapons[w] += 1
					return
			# Depois adiciona novas armas
			if weapons.size() < 4:
				for w in available_weapons:
					if not weapons.has(w):
						weapons[w] = 1
						return
			# Depois passivas
			if passives.size() < 4:
				for p in PASSIVE_POOL:
					if not passives.has(p):
						passives[p] = 1
						return
						
		AIStrategy.BALANCED, AIStrategy.RANDOM:
			# Alterna entre upar armas e passivas
			if rng.randf() > 0.5 and weapons.size() > 0:
				var w_keys: Array = weapons.keys()
				var chosen_w: String = w_keys[rng.randi_range(0, w_keys.size() - 1)]
				if weapons[chosen_w] < 5:
					weapons[chosen_w] += 1
				elif weapons.size() < 4:
					for w in available_weapons:
						if not weapons.has(w):
							weapons[w] = 1
							break
			else:
				var chosen_p: String = PASSIVE_POOL[rng.randi_range(0, PASSIVE_POOL.size() - 1)]
				passives[chosen_p] = mini(5, passives.get(chosen_p, 0) + 1)

## Avalia evolução de arma no baú se requisitos forem cumpridos (CA-07)
static func _evaluate_chest_evolution(weapons: Dictionary, passives: Dictionary) -> void:
	var passive_ids: Array[String] = []
	for p in passives:
		passive_ids.append(str(p))
		
	var to_replace: Dictionary = {}
	for w_id in weapons:
		var lvl: int = weapons[w_id]
		var evo: Dictionary = WeaponEvolutionManager.check_evolution_eligible(w_id, lvl, passive_ids)
		if not evo.is_empty():
			to_replace[w_id] = evo["evolved_id"]
			break # 1 evolução por baú
			
	for old_w in to_replace:
		var new_w: String = to_replace[old_w]
		weapons.erase(old_w)
		weapons[new_w] = 5
