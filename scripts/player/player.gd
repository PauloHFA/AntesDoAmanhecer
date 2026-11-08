class_name Player
extends CharacterBody2D

## Controlador do Vigilante - Classe Benzedeira (Seção 6, RF-11, RF-12)
## Inclui movimentação 8 direções, cura passiva de arruda e Especial de Fúria "Reza Forte".

@export_group("Atributos Básicos")
@export var base_speed: float = 120.0
@export var max_health: int = 100
@export var invulnerability_duration: float = 0.5

@export_group("Fúria Noturna & Especial")
@export var max_fury: float = 100.0
@export var current_fury: float = 0.0
@export var special_duration: float = 5.0
var is_reza_forte_active: bool = false
var reza_forte_timer: float = 0.0

# Passiva da Benzedeira: Cura 1 PV a cada 5s
var benzedeira_heal_timer: float = 0.0

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
		
	if has_node("/root/EventBus"):
		EventBus.enemy_killed.connect(_on_enemy_killed)
		EventBus.player_healed.emit(current_health, max_health)
		EventBus.fury_changed.emit(current_fury, max_fury)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# Passiva da Benzedeira: cura 1 PV a cada 5 segundos
	benzedeira_heal_timer += delta
	if benzedeira_heal_timer >= 5.0:
		benzedeira_heal_timer = 0.0
		heal(1)
		
	# Atualiza Especial "Reza Forte"
	if is_reza_forte_active:
		reza_forte_timer -= delta
		_pulse_reza_forte_damage()
		if reza_forte_timer <= 0.0:
			_end_reza_forte()
		queue_redraw()
	else:
		# Checa ativação do especial por tecla
		if Input.is_action_just_pressed("fury_special") and current_fury >= max_fury:
			activate_reza_forte()
			
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

func update_facing(dir: Vector2) -> void:
	if not visual_root:
		return
	if dir.x < 0:
		visual_root.scale.x = -1.0
	elif dir.x > 0:
		visual_root.scale.x = 1.0

## Ativa o Especial "Reza Forte" da Benzedeira (Seção 6, RF-12)
func activate_reza_forte() -> void:
	is_reza_forte_active = true
	reza_forte_timer = special_duration
	current_fury = 0.0
	is_invulnerable = true
	
	if has_node("/root/EventBus"):
		EventBus.fury_changed.emit(current_fury, max_fury)
		EventBus.fury_activated.emit(special_duration)
		
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.6)
		j.hit_stop(80.0)

func _pulse_reza_forte_damage() -> void:
	var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	if swarm_nodes.size() > 0:
		var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager
		# Onda sagrada que empurra e fere tudo num raio de 140px
		swarm.damage_in_radius(global_position, 140.0, 35.0, 28.0)

func _end_reza_forte() -> void:
	is_reza_forte_active = false
	is_invulnerable = false
	queue_redraw()

func _draw() -> void:
	if is_reza_forte_active:
		# Aura sagrada dourada pulsando
		var pulse: float = (sin(Time.get_ticks_msec() * 0.01) * 10.0) + 130.0
		draw_circle(Vector2.ZERO, pulse, Color(1.0, 0.9, 0.3, 0.22))
		draw_arc(Vector2.ZERO, pulse, 0.0, TAU, 32, Color(1.0, 0.95, 0.5, 0.8), 3.0)

func take_damage(amount: int) -> void:
	if is_invulnerable or is_dead or amount <= 0 or is_reza_forte_active:
		return
		
	current_health = clampi(current_health - amount, 0, max_health)
	is_invulnerable = true
	invuln_timer.start()
	
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
	if is_dead or is_reza_forte_active:
		return
	current_fury = clampf(current_fury + amount, 0.0, max_fury)
	if has_node("/root/EventBus"):
		EventBus.fury_changed.emit(current_fury, max_fury)

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	add_fury(2.5) # 40 abates enchem a barra completa de fúria

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	if has_node("/root/EventBus"):
		EventBus.player_died.emit()

func _on_invulnerability_timeout() -> void:
	if not is_reza_forte_active:
		is_invulnerable = false
	modulate.a = 1.0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var damage: int = 10
		if "damage" in area:
			damage = area.damage
		take_damage(damage)
