class_name WeaponFusionManager
extends RefCounted

## Gerenciador de Fusões Secretas de Armas (RF-09, Seção 7.3)
## Permite que duas armas já evoluídas se fundam em uma arma mítica secreta.

const SECRET_FUSIONS: Dictionary = {
	"aurora_rubra": {
		"fusion_id": "aurora_rubra",
		"name": "Aurora Rubra",
		"desc": "Sol flamejante teleguiado que persegue o inimigo mais forte e incinera o mapa.",
		"required_evolved_1": "boitata",
		"required_evolved_2": "sol_pequeno"
	},
	"tempestade_sertao": {
		"fusion_id": "tempestade_sertao",
		"name": "Tempestade do Sertão",
		"desc": "Tiros congelantes com ricochete infinito entre os monstros.",
		"required_evolved_1": "trovao_sertao",
		"required_evolved_2": "repique_final"
	},
	"bencao_total": {
		"fusion_id": "bencao_total",
		"name": "Bênção Total",
		"desc": "Aura sagrada suprema que cura o Vigilante continuamente e calcina a horda.",
		"required_evolved_1": "coroa_arruda",
		"required_evolved_2": "diluvio_bento"
	}
}

## Avalia se o jogador possui as duas armas evoluídas necessárias para uma fusão secreta
static func check_fusion_eligible(equipped_evolved_ids: Array[String]) -> Dictionary:
	for fusion_key in SECRET_FUSIONS:
		var data: Dictionary = SECRET_FUSIONS[fusion_key]
		var req1: String = data["required_evolved_1"]
		var req2: String = data["required_evolved_2"]
		
		if equipped_evolved_ids.has(req1) and equipped_evolved_ids.has(req2):
			return data
			
	return {}
