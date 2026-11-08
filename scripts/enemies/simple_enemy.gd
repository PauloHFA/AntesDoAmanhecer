class_name SimpleEnemy
extends CharacterBody2D

## Inimigo básico para o protótipo da Sprint 1 (Alma Penada / Morcego)
## Persegue o jogador diretamente e solta gema de XP ao ser derrotado.

@export var enemy_name: String = "Alma Penada"
@export var max_health: float = 20.0
@export var speed: float = 65.0
@export var contact_damage: int = 10
@export var xp_value: int = 5

var current_health: float
var player_ref: Node2D = null
var is_dying: bool = false

@onready var visual: Node2D = $Visual
@onready var hit_flash_timer: Timer = $HitFlashTimer

const XP_GEM_SCENE: PackedScene = preload("res://scenes/pickups/xp_gem.tscn")

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	
	hit_flash_timer.one_shot = true
	hit_flash_timer.wait_time = 0.08
	hit_flash_timer.timeout.connect(_on_hit_flash_timeout)
	
	_find_player()

func _physics_process(_delta: float) -> void:
	if is_dying:
		return
		
	if not is_instance_valid(player_ref):
		_find_player()
		return
		
	var direction: Vector2 = (player_ref.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Orientação visual (olhar para o jogador)
	if visual:
		if direction.x < 0:
			visual.scale.x = -1.0
		elif direction.x > 0:
			visual.scale.x = 1.0
			
	move_and_slide()
	
	# Verifica colisão direta com o jogador
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(contact_damage)

func take_damage(amount: float, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dying:
		return
		
	current_health -= amount
	
	# Flash visual de impacto (Juice inicial)
	modulate = Color(2.5, 2.5, 2.5, 1.0) # Brilho intenso
	hit_flash_timer.start()
	
	# Aplica leve empurrão
	if knockback != Vector2.ZERO:
		global_position += knockback
		
	if current_health <= 0.0:
		die()

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	# Notifica o EventBus
	if has_node("/root/EventBus"):
		EventBus.enemy_killed.emit(enemy_name, global_position, true)
		
	# Instancia a gema de XP
	_spawn_xp_gem()
	queue_free()

func _spawn_xp_gem() -> void:
	if XP_GEM_SCENE:
		var gem: Node2D = XP_GEM_SCENE.instantiate() as Node2D
		gem.global_position = global_position
		if gem.has_method("set_xp_value"):
			gem.set_xp_value(xp_value)
		get_parent().call_deferred("add_child", gem)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Node2D

func _on_hit_flash_timeout() -> void:
	modulate = Color.WHITE
