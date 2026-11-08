class_name DeathParticlesPool
extends Node2D

## Pool de Efeitos de Morte em Confete, Cinzas e Estrelas (Seção 10.2)
## Estoura partículas coloridas e reutiliza instâncias para respeitar o orçamento de 2 ms de efeitos.

@export var pool_size: int = 24

var particle_nodes: Array[CPUParticles2D] = []
var free_particles: Array[CPUParticles2D] = []

func _ready() -> void:
	add_to_group("death_fx_pool")
	_initialize_pool()

func _initialize_pool() -> void:
	for i in range(pool_size):
		var p: CPUParticles2D = CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 0.95
		p.lifetime = 0.3
		p.amount = 14
		p.spread = 180.0
		p.initial_velocity_min = 45.0
		p.initial_velocity_max = 95.0
		p.gravity = Vector2(0.0, 60.0)
		p.scale_amount_min = 2.0
		p.scale_amount_max = 3.5
		p.color = Color(1.0, 0.85, 0.3, 1.0) # Confete dourado/mágico
		add_child(p)
		free_particles.append(p)
		particle_nodes.append(p)

func spawn_death_burst(world_pos: Vector2) -> void:
	if free_particles.is_empty():
		return
		
	var p: CPUParticles2D = free_particles.pop_back()
	p.global_position = world_pos
	# Alterna cores de confete caricato (rosa, ciano, dourado)
	var colors: Array[Color] = [
		Color(1.0, 0.4, 0.6), # Rosa
		Color(0.2, 0.9, 1.0), # Ciano
		Color(1.0, 0.85, 0.2), # Dourado
		Color(0.6, 0.4, 0.9)  # Roxo
	]
	p.color = colors[randi() % colors.size()]
	p.restart()
	p.emitting = true
	
	# Retorna ao pool após o término
	get_tree().create_timer(0.35, false, false, true).timeout.connect(func() -> void:
		free_particles.append(p)
	)
