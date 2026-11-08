class_name BossMapinguari
extends CharacterBody2D

## Primeiro Chefe do Ato 1: Mapinguari (Seção 8.1, RF-13, CA-10)
## Criatura colossal da floresta corrompida pela Noite. Possui ataque sísmico e investida.

@export var boss_name: String = "Mapinguari"
@export var max_health: float = 1200.0
@export var speed: float = 50.0
@export var contact_damage: int = 20

var current_health: float
var player_ref: Player = null
var is_dying: bool = false

# Máquina de estados de ataque
enum BossState { CHASE, SLAM_TELEGRAPH, SLAM_STRIKE, CHARGE }
var state: BossState = BossState.CHASE

var slam_cooldown_timer: float = 5.0
var slam_telegraph_timer: float = 0.0
var charge_cooldown_timer: float = 11.0
var charge_duration_timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual
@onready var slam_radius: float = 90.0

const CHEST_SCENE: PackedScene = preload("res://scenes/pickups/treasure_chest.tscn")

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	add_to_group("bosses")
	_find_player()
	
	if has_node("/root/EventBus"):
		EventBus.boss_spawned.emit(boss_name)
		
	# Apresentação do Chefe: tremor de introdução
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.7)

func _physics_process(delta: float) -> void:
	if is_dying:
		return
		
	if not is_instance_valid(player_ref):
		_find_player()
		return
		
	slam_cooldown_timer -= delta
	charge_cooldown_timer -= delta
	
	match state:
		BossState.CHASE:
			var to_player: Vector2 = (player_ref.global_position - global_position).normalized()
			velocity = to_player * speed
			if visual and to_player.x != 0:
				visual.scale.x = -1.0 if to_player.x < 0 else 1.0
				
			move_and_slide()
			
			if charge_cooldown_timer <= 0.0:
				_start_charge()
			elif slam_cooldown_timer <= 0.0 and global_position.distance_to(player_ref.global_position) <= slam_radius + 40.0:
				_start_slam_telegraph()
				
		BossState.SLAM_TELEGRAPH:
			velocity = Vector2.ZERO
			slam_telegraph_timer -= delta
			queue_redraw()
			if slam_telegraph_timer <= 0.0:
				_execute_slam()
				
		BossState.CHARGE:
			velocity = charge_direction * 150.0
			charge_duration_timer -= delta
			move_and_slide()
			if charge_duration_timer <= 0.0:
				state = BossState.CHASE
				charge_cooldown_timer = 10.0

	_check_contact_damage()

func _start_slam_telegraph() -> void:
	state = BossState.SLAM_TELEGRAPH
	slam_telegraph_timer = 0.9 # 900ms de aviso visual (telegraph)

func _execute_slam() -> void:
	state = BossState.CHASE
	slam_cooldown_timer = 5.5
	queue_redraw()
	
	# Efeito de tremor de tela
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.55)
		j.hit_stop(60.0)
		
	# Dano em área no jogador
	if is_instance_valid(player_ref):
		if global_position.distance_to(player_ref.global_position) <= slam_radius:
			player_ref.take_damage(25)

func _start_charge() -> void:
	state = BossState.CHARGE
	charge_duration_timer = 1.3
	charge_direction = (player_ref.global_position - global_position).normalized()

func _check_contact_damage() -> void:
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(contact_damage)

func take_damage(amount: float, _knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dying:
		return
	current_health -= amount
	
	# Números de dano
	var d_pools: Array[Node] = get_tree().get_nodes_in_group("damage_pool")
	if d_pools.size() > 0:
		var pool: DamageNumberPool = d_pools[0] as DamageNumberPool
		pool.spawn_number(global_position + Vector2(0, -20), amount, amount >= 30.0)
		
	# Flash visual
	modulate = Color(2.0, 2.0, 2.0, 1.0)
	get_tree().create_timer(0.06, false, false, true).timeout.connect(func() -> void:
		modulate = Color.WHITE
	)
	
	if current_health <= 0.0:
		die()

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	if has_node("/root/EventBus"):
		EventBus.boss_defeated.emit(boss_name)
		EventBus.enemy_killed.emit(boss_name, global_position, false)
		
	# Efeitos épicos de morte (Seção 10.2)
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.85)
		j.hit_stop(90.0)
		
	var fx_pools: Array[Node] = get_tree().get_nodes_in_group("death_fx_pool")
	if fx_pools.size() > 0:
		var fx: DeathParticlesPool = fx_pools[0] as DeathParticlesPool
		fx.spawn_death_burst(global_position)
		
	# Deixa um baú lendário
	if CHEST_SCENE:
		var chest: Node2D = CHEST_SCENE.instantiate() as Node2D
		chest.global_position = global_position
		get_parent().call_deferred("add_child", chest)
		
	queue_free()

func _draw() -> void:
	if state == BossState.SLAM_TELEGRAPH:
		# Telegraph circular vermelho indicando área de impacto
		var progress: float = 1.0 - (slam_telegraph_timer / 0.9)
		draw_arc(Vector2.ZERO, slam_radius, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, 0.8), 2.0)
		draw_circle(Vector2.ZERO, slam_radius * progress, Color(1.0, 0.2, 0.2, 0.25))

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
