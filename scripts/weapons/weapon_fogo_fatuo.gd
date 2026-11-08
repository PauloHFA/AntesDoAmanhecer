class_name WeaponFogoFatuo
extends Node2D

## Arma: Fogo-Fátuo (Seção 7.1)
## Lança orbes azuis fantasmagóricos teleguiados que perseguem os monstros mais próximos.
## Evolui para "Boitatá", a serpente colossal de fogo.

@export var base_damage: float = 22.0
@export var cooldown: float = 1.3
@export var orbs_per_shot: int = 2
@export var is_evolved: bool = false # Boitatá

var timer: float = 0.0

class HomingOrb:
	var position: Vector2
	var target_pos: Vector2
	var velocity: Vector2
	var lifetime: float
	var damage: float

var active_orbs: Array[HomingOrb] = []

func _ready() -> void:
	add_to_group("weapons")

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= cooldown:
		timer = 0.0
		_cast_orbs()
		
	_update_orbs(delta)
	queue_redraw()

func _cast_orbs() -> void:
	var count: int = orbs_per_shot if not is_evolved else orbs_per_shot + 3
	for i in range(count):
		var orb: HomingOrb = HomingOrb.new()
		orb.position = global_position
		var angle: float = randf() * TAU
		orb.velocity = Vector2(cos(angle), sin(angle)) * 90.0
		orb.damage = base_damage * (1.8 if is_evolved else 1.0)
		orb.lifetime = 2.4
		active_orbs.append(orb)

func _update_orbs(delta: float) -> void:
	var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager if swarm_nodes.size() > 0 else null
	
	var i: int = active_orbs.size() - 1
	while i >= 0:
		var orb: HomingOrb = active_orbs[i]
		orb.lifetime -= delta
		
		# Procura alvo na grade espacial
		if swarm and swarm.spatial_grid:
			var nearby: PackedInt32Array = swarm.spatial_grid.query_radius(orb.position, 180.0, swarm.positions)
			if nearby.size() > 0:
				var target_id: int = nearby[0]
				if target_id < swarm.positions.size():
					var to_target: Vector2 = (swarm.positions[target_id] - orb.position).normalized()
					orb.velocity = orb.velocity.lerp(to_target * 240.0, delta * 5.0)
					
		orb.position += orb.velocity * delta
		
		# Checa acerto
		if swarm:
			var hits: int = swarm.damage_in_radius(orb.position, 16.0, orb.damage, 12.0)
			if hits > 0:
				orb.lifetime = 0.0
				
		if orb.lifetime <= 0.0:
			active_orbs.remove_at(i)
		i -= 1

func _draw() -> void:
	for orb in active_orbs:
		var local_pos: Vector2 = to_local(orb.position)
		var orb_col: Color = Color(0.2, 0.85, 1.0, 0.9) if not is_evolved else Color(1.0, 0.4, 0.1, 0.9)
		draw_circle(local_pos, 5.0, orb_col)
		draw_circle(local_pos, 8.0, Color(orb_col.r, orb_col.g, orb_col.b, 0.3))

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 40.0
	cooldown = 0.8
	orbs_per_shot = 4
