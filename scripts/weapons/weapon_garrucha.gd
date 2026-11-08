class_name WeaponGarrucha
extends Node2D

## Arma: Garrucha (Dano à distância do Cangaceiro - Seção 7.1)
## Dispara tiros perfurantes na direção do movimento/olhar do jogador.
## Evolui para "Trovão do Sertão" com tiros duplos em leque de penetração total.

@export var base_damage: float = 18.0
@export var cooldown: float = 0.85
@export var bullet_speed: float = 340.0
@export var pierce_count: int = 1
@export var is_evolved: bool = false # Trovão do Sertão

var attack_timer: float = 0.0
var player_ref: Player = null

class Bullet:
	var position: Vector2
	var velocity: Vector2
	var remaining_pierce: int
	var lifetime: float
	var damage: float

var active_bullets: Array[Bullet] = []

func _ready() -> void:
	add_to_group("weapons")
	_find_player()

func _physics_process(delta: float) -> void:
	attack_timer += delta
	if attack_timer >= cooldown:
		attack_timer = 0.0
		_fire()
		
	_update_bullets(delta)
	queue_redraw()

func _fire() -> void:
	if not is_instance_valid(player_ref):
		_find_player()
		if not is_instance_valid(player_ref):
			return
			
	var fire_dir: Vector2 = player_ref.facing_direction
	if fire_dir == Vector2.ZERO:
		fire_dir = Vector2.RIGHT
		
	var origin: Vector2 = global_position
	
	if is_evolved:
		# Trovão do Sertão: tiros duplos em leque perfurando tudo
		_spawn_bullet(origin, fire_dir.rotated(0.12), base_damage * 1.5, 999)
		_spawn_bullet(origin, fire_dir.rotated(-0.12), base_damage * 1.5, 999)
	else:
		_spawn_bullet(origin, fire_dir, base_damage, pierce_count)

func _spawn_bullet(pos: Vector2, dir: Vector2, dmg: float, pierce: int) -> void:
	var b: Bullet = Bullet.new()
	b.position = pos
	b.velocity = dir.normalized() * bullet_speed
	b.damage = dmg
	b.remaining_pierce = pierce
	b.lifetime = 1.2
	active_bullets.append(b)

func _update_bullets(delta: float) -> void:
	var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager if swarm_nodes.size() > 0 else null
	
	var i: int = active_bullets.size() - 1
	while i >= 0:
		var b: Bullet = active_bullets[i]
		b.lifetime -= delta
		b.position += b.velocity * delta
		
		# Checa colisão com o swarm manager
		if swarm:
			var hits: int = swarm.damage_in_radius(b.position, 10.0, b.damage, 14.0)
			if hits > 0:
				b.remaining_pierce -= hits
				
		if b.lifetime <= 0.0 or b.remaining_pierce <= 0:
			active_bullets.remove_at(i)
		i -= 1

func _draw() -> void:
	for b in active_bullets:
		var local_pos: Vector2 = to_local(b.position)
		var bullet_col: Color = Color(1.0, 0.9, 0.3) if not is_evolved else Color(0.3, 0.9, 1.0)
		draw_circle(local_pos, 3.5, bullet_col)
		draw_line(local_pos, local_pos - (b.velocity.normalized() * 8.0), bullet_col, 1.5)

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 32.0
	cooldown = 0.6
	pierce_count = 999

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
