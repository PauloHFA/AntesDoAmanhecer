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
	
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.22)
		j.hit_stop(35.0)

func _draw() -> void:
	if wave_radius < 0.0:
		return
		
	var max_r: float = wave_max_radius * (1.5 if is_evolved else 1.0)
	var alpha: float = 1.0 - (wave_radius / max_r)
	var wave_color: Color = Color(1.0, 0.92, 0.4, alpha * 0.85) if not is_evolved else Color(0.3, 0.95, 1.0, alpha * 0.95)
	var wave_color_inner: Color = Color(1.0, 0.75, 0.2, alpha * 0.45) if not is_evolved else Color(0.2, 0.5, 1.0, alpha * 0.45)
	
	# Onda acústica primária de choque (Borda externa viva)
	draw_arc(Vector2.ZERO, wave_radius, 0.0, TAU, 36, wave_color, 4.0)
	
	# Onda secundária de ressonância (Eco do sino)
	if wave_radius > 25.0:
		draw_arc(Vector2.ZERO, wave_radius * 0.78, 0.0, TAU, 32, wave_color_inner, 2.0)
		
	# Pêndulo do sino místico badalando acima da cabeça
	if wave_radius < max_r * 0.6:
		var bell_pos: Vector2 = Vector2(0, -32)
		var swing: float = sin(wave_radius * 0.15) * 6.0
		var bell_poly: PackedVector2Array = PackedVector2Array([
			bell_pos + Vector2(-6 + swing, 0),
			bell_pos + Vector2(6 + swing, 0),
			bell_pos + Vector2(4 + swing, -10),
			bell_pos + Vector2(-4 + swing, -10)
		])
		draw_colored_polygon(bell_poly, Color(1.0, 0.85, 0.3, alpha))
		draw_circle(bell_pos + Vector2(swing, 2), 2.5, Color(1.0, 0.95, 0.6, alpha))

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 55.0
	cooldown = 1.5
	wave_max_radius = 180.0
