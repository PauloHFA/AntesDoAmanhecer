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
var muzzle_flash_timer: float = 0.0
var last_fire_dir: Vector2 = Vector2.RIGHT
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
		
	if muzzle_flash_timer > 0.0:
		muzzle_flash_timer -= delta
		
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
		
	last_fire_dir = fire_dir
	muzzle_flash_timer = 0.09
	
	# Coice da arma no corpo do jogador (Recoil kickback)
	if is_instance_valid(player_ref) and player_ref.visual_root:
		player_ref.visual_root.position -= fire_dir * 3.5
		
	var audio_mgrs: Array[Node] = get_tree().get_nodes_in_group("audio")
	if audio_mgrs.size() > 0:
		var audio: AudioManager = audio_mgrs[0] as AudioManager
		audio.play_sfx_gun()
		
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
	# Clarão de Pólvora e Fogo na boca do cano (Muzzle Flash)
	if muzzle_flash_timer > 0.0:
		var muzzle_pos: Vector2 = last_fire_dir * 18.0
		var flash_color: Color = Color(2.5, 2.2, 0.6, 1.0) if not is_evolved else Color(0.8, 2.2, 2.5, 1.0)
		
		# Cruz de labareda explosiva
		var perp: Vector2 = Vector2(-last_fire_dir.y, last_fire_dir.x)
		var star_poly: PackedVector2Array = PackedVector2Array([
			muzzle_pos + (last_fire_dir * 9.0),
			muzzle_pos + (perp * 4.0),
			muzzle_pos - (last_fire_dir * 4.0),
			muzzle_pos - (perp * 4.0)
		])
		draw_colored_polygon(star_poly, flash_color)
		draw_circle(muzzle_pos, 4.0, Color(2.5, 2.5, 2.5, 0.9))
		# Fumaça cinza de pólvora
		draw_circle(muzzle_pos + perp * 2.0, 3.0, Color(0.6, 0.6, 0.65, 0.45))
		
	# Projéteis rápidos com rastro alongado e núcleo incandescente
	for b in active_bullets:
		var local_pos: Vector2 = to_local(b.position)
		var bullet_dir: Vector2 = b.velocity.normalized()
		var bullet_col: Color = Color(1.0, 0.85, 0.25) if not is_evolved else Color(0.2, 0.85, 1.0)
		var core_col: Color = Color(2.5, 2.5, 2.0)
		
		# Rastro alongado (Tracer)
		var tail_pos: Vector2 = local_pos - (bullet_dir * 14.0)
		draw_line(local_pos, tail_pos, bullet_col, 2.5)
		# Cabeça do projétil incandescente
		draw_circle(local_pos, 3.0, core_col)
		draw_circle(local_pos - (bullet_dir * 3.0), 2.0, bullet_col)

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 32.0
	cooldown = 0.6
	pierce_count = 999

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
