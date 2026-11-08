class_name EnemyBestiaryData
extends RefCounted

## Catálogo de Definições e Comportamentos do Bestiário (Seção 8.1, RF-13)
## Define velocidades, resistências, IA e minuto de aparição de cada monstro do folclore.

const BESTIARY_CATALOG: Dictionary = {
	"morcego_lunar": {
		"name": "Morcego Lunar",
		"min_spawn_minute": 0.0,
		"base_hp": 12.0,
		"speed": 85.0,
		"behavior": "straight_swarm",
		"description": "Enxame rápido que voa em linha reta."
	},
	"alma_penada": {
		"name": "Alma Penada",
		"min_spawn_minute": 0.0,
		"base_hp": 22.0,
		"speed": 55.0,
		"behavior": "chase",
		"description": "Espírito lento e resistente que persegue sem descanso."
	},
	"lobisomem": {
		"name": "Lobisomem Magricela",
		"min_spawn_minute": 3.0,
		"base_hp": 35.0,
		"speed": 95.0,
		"behavior": "pack_rush",
		"description": "Rápido e voraz, ataca em bandos coordenados."
	},
	"saci_arteiro": {
		"name": "Saci Arteiro",
		"min_spawn_minute": 5.0,
		"base_hp": 40.0,
		"speed": 75.0,
		"behavior": "zigzag_jump",
		"description": "Movimenta-se em zigue-zague imprevisível com pulos curtos."
	},
	"mula_sem_cabeca": {
		"name": "Mula-sem-cabeça",
		"min_spawn_minute": 8.0,
		"base_hp": 85.0,
		"speed": 60.0,
		"charge_speed": 160.0,
		"behavior": "charge_line",
		"description": "Investida furiosa em linha reta com chamas pelo pescoço."
	},
	"curupira": {
		"name": "Curupira",
		"min_spawn_minute": 10.0,
		"base_hp": 90.0,
		"speed": 65.0,
		"behavior": "slow_trap",
		"description": "Deixa pegadas mágicas invertidas que desaceleram o Vigilante."
	},
	"boitata_elite": {
		"name": "Boitatá (Elite)",
		"min_spawn_minute": 12.0,
		"base_hp": 250.0,
		"speed": 80.0,
		"behavior": "serpent_cross",
		"description": "Serpente colossal de fogo que atravessa a tela."
	}
}

## Calcula o vetor de movimento característico para o comportamento do Saci (zigue-zague senoidal)
static func calculate_saci_zigzag(origin: Vector2, target: Vector2, speed: float, time_sec: float) -> Vector2:
	var forward: Vector2 = (target - origin).normalized()
	var perpendicular: Vector2 = Vector2(-forward.y, forward.x)
	var wave: float = sin(time_sec * 6.0) * 0.8
	return (forward + (perpendicular * wave)).normalized() * speed

## Verifica quais inimigos estão liberados para surgir no minuto atual
static func get_available_enemies_for_minute(minute: float) -> Array[String]:
	var list: Array[String] = []
	for id in BESTIARY_CATALOG:
		if minute >= BESTIARY_CATALOG[id]["min_spawn_minute"]:
			list.append(id)
	return list
