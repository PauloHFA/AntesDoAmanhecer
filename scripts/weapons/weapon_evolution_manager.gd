class_name WeaponEvolutionManager
extends RefCounted

## Gerenciador de Receitas e Evoluções de Armas (RF-08, CA-07, Seção 7.1)
## Avalia se a arma no nível máximo e a passiva correspondente qualificam a evolução ao abrir um baú.

const EVOLUTION_RECIPES: Dictionary = {
	"galho_arruda": {
		"required_passive": "escapulario",
		"evolved_id": "coroa_arruda",
		"evolved_name": "Coroa de Arruda",
		"desc": "Dois anéis orbitais e aura sagrada de cura."
	},
	"garrucha": {
		"required_passive": "ferradura",
		"evolved_id": "trovao_sertao",
		"evolved_name": "Trovão do Sertão",
		"desc": "Tiros duplos em leque com perfuração total."
	},
	"fogo_fatuo": {
		"required_passive": "chapeu_de_couro",
		"evolved_id": "boitata",
		"evolved_name": "Boitatá",
		"desc": "Serpente colossal de fogo teleguiada."
	},
	"facao": {
		"required_passive": "ferradura",
		"evolved_id": "facao_furioso",
		"evolved_name": "Facão Furioso",
		"desc": "Giro completo de 360 graus devastador."
	},
	"sino": {
		"required_passive": "garrafada",
		"evolved_id": "repique_final",
		"evolved_name": "Repique Final",
		"desc": "Ondas sonoras congelantes contínuas."
	}
}

## Verifica se uma arma é elegível para evolução no baú (CA-07)
static func check_evolution_eligible(weapon_id: String, weapon_level: int, equipped_passives: Array[String]) -> Dictionary:
	if not EVOLUTION_RECIPES.has(weapon_id):
		return {}
		
	var recipe: Dictionary = EVOLUTION_RECIPES[weapon_id]
	var required_passive: String = recipe["required_passive"]
	
	# Requisito do GDD: Arma no nível máximo (nível 8 ou protótipo nível >= 5) E passiva equipada
	if weapon_level >= 5 and equipped_passives.has(required_passive):
		return recipe
		
	return {}
