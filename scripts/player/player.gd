class_name Player
extends CharacterBody2D

## Controlador do Vigilante (Jogador)
## Responsável pela movimentação em 8 direções, atributos e câmera.

@export_group("Atributos Básicos")
@export var base_speed: float = 120.0
@export var max_health: int = 100
@export var invulnerability_duration: float = 0.5

@export_group("Fúria Noturna")
@export var max_fury: float = 100.0
@export var current_fury: float = 0.0

var current_health: int
var is_invulnerable: bool = false
var facing_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false

@onready var visual_root: Node2D = $Visual
@onready var camera: Camera2D = $Camera2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var invuln_timer: Timer = $InvulnerabilityTimer

func _ready() -> void:
	current_health = max_health
	invuln_timer.wait_time = invulnerability_duration
	invuln_timer.one_shot = true
	invuln_timer.timeout.connect(_on_invulnerability_timeout)
	
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
		
	# Notifica estado inicial
	if has_node("/root/EventBus"):
		EventBus.player_healed.emit(current_health, max_health)
		EventBus.fury_changed.emit(current_fury, max_fury)

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var input_vector: Vector2 = get_movement_input()
	
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		velocity = input_vector * base_speed
		update_facing(input_vector)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

## Retorna o vetor de movimentação em 8 direções normalizado
func get_movement_input() -> Vector2:
	var x: float = Input.get_axis("move_left", "move_right")
	var y: float = Input.get_axis("move_up", "move_down")
	var dir: Vector2 = Vector2(x, y)
	
	if dir.length_squared() > 1.0:
		dir = dir.normalized()
		
	return dir

## Atualiza a orientação visual do personagem
func update_facing(dir: Vector2) -> void:
	if not visual_root:
		return
	if dir.x < 0:
		visual_root.scale.x = -1.0
	elif dir.x > 0:
		visual_root.scale.x = 1.0

## Recebe dano com período de invulnerabilidade (i-frames)
func take_damage(amount: int) -> void:
	if is_invulnerable or is_dead or amount <= 0:
		return
		
	current_health = clampi(current_health - amount, 0, max_health)
	is_invulnerable = true
	invuln_timer.start()
	
	# Feedback visual de piscar
	modulate.a = 0.5
	
	if has_node("/root/EventBus"):
		EventBus.player_damaged.emit(current_health, max_health)
		
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_health = clampi(current_health + amount, 0, max_health)
	if has_node("/root/EventBus"):
		EventBus.player_healed.emit(current_health, max_health)

func add_fury(amount: float) -> void:
	if is_dead:
		return
	current_fury = clampf(current_fury + amount, 0.0, max_fury)
	if has_node("/root/EventBus"):
		EventBus.fury_changed.emit(current_fury, max_fury)

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	if has_node("/root/EventBus"):
		EventBus.player_died.emit()

func _on_invulnerability_timeout() -> void:
	is_invulnerable = false
	modulate.a = 1.0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var damage: int = 10
		if "damage" in area:
			damage = area.damage
		take_damage(damage)
