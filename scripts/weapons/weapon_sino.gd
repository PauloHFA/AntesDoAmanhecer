class_name WeaponSino
extends Node2D

## Arma: Sino da Capela (Pulso de Área - Seção 7.1)
## Emite ondas sonoras em anel centradas no jogador que ferem e afastam inimigos.
## Evolui para "Repique Final" (ondas que congelam/desaceleram e causam dano massivo).

@export var base_damage: float = 30.0
@export var cooldown: float = 2.2
@export var wave_max_radius: float = 130.0
@export var is_evolved: bool = false # Repique Final

var timer: float = 0.0
var wave_radius: float = -1.0

func _ready() -> void:
	add_to_group("weapons")

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= cooldown:
		timer = 0.0
		_trigger_bell_toll()
		
	if wave_radius >= 0.0:
		wave_radius += delta * 240.0
		var max_r: float = wave_max_radius * (1.5 if is_evolved else 1.0)
		
		# Dano contínuo da onda expansiva
		var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
		if swarm_nodes.size() > 0:
			var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager
			swarm.damage_in_radius(global_position, wave_radius, base_damage * (0.3 if not is_evolved else 0.6), 15.0)
			
		if wave_radius >= max_r:
			wave_radius = -1.0
		queue_redraw()

func _trigger_bell_toll() -> void:
	wave_radius = 10.0

func _draw() -> void:
	if wave_radius < 0.0:
		return
		
	var max_r: float = wave_max_radius * (1.5 if is_evolved else 1.0)
	var alpha: float = 1.0 - (wave_radius / max_r)
	var wave_color: Color = Color(1.0, 0.9, 0.4, alpha * 0.8) if not is_evolved else Color(0.4, 0.9, 1.0, alpha * 0.9)
	draw_arc(Vector2.ZERO, wave_radius, 0.0, TAU, 32, wave_color, 3.5)

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 55.0
	cooldown = 1.5
	wave_max_radius = 180.0
