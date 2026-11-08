class_name NightCycleController
extends CanvasModulate

## Controlador do Relógio da Noite e Iluminação do Céu (Seção 5.6, CA-11)
## Modula a paleta de cores da noite até o amanhecer às 00:00.

@export var match_duration_seconds: float = 1200.0 # 20 minutos de sobrevivência
@export var is_dawn: bool = false

var elapsed_seconds: float = 0.0
var time_remaining: float = 1200.0

# Cores da noite ao amanhecer (Seção 10.1)
const COLOR_MIDNIGHT: Color = Color(0.45, 0.45, 0.65, 1.0) # Início da partida (azuis noturnos)
const COLOR_DEEP_NIGHT: Color = Color(0.28, 0.25, 0.45, 1.0) # Metade da noite (roxo denso)
const COLOR_PRE_DAWN: Color = Color(0.35, 0.42, 0.60, 1.0) # Madrugada fria
const COLOR_SUNRISE: Color = Color(1.3, 1.25, 1.1, 1.0) # Amanhecer glorioso (luz do sol)

func _ready() -> void:
	time_remaining = match_duration_seconds
	color = COLOR_MIDNIGHT

func _process(delta: float) -> void:
	if is_dawn:
		return
		
	elapsed_seconds += delta
	time_remaining = maxf(0.0, match_duration_seconds - elapsed_seconds)
	
	if has_node("/root/EventBus"):
		EventBus.night_clock_updated.emit(time_remaining)
		
	_update_sky_color()
	
	if time_remaining <= 0.0 and not is_dawn:
		_trigger_dawn_victory()

func _update_sky_color() -> void:
	var progress: float = elapsed_seconds / match_duration_seconds
	
	if progress < 0.5:
		# De meia-noite a noite profunda
		color = COLOR_MIDNIGHT.lerp(COLOR_DEEP_NIGHT, progress * 2.0)
	elif progress < 0.9:
		# De noite profunda a madrugada
		var sub_p: float = (progress - 0.5) / 0.4
		color = COLOR_DEEP_NIGHT.lerp(COLOR_PRE_DAWN, sub_p)
	else:
		# Reta final até os primeiros raios de sol
		var sub_p: float = (progress - 0.9) / 0.1
		color = COLOR_PRE_DAWN.lerp(COLOR_SUNRISE, sub_p)

func _trigger_dawn_victory() -> void:
	is_dawn = true
	color = COLOR_SUNRISE
	
	# Elimina todos os inimigos da noite (CA-11: "inimigos viram cinzas e confete")
	var swarms: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	for s in swarms:
		if s.has_method("clear_all"):
			s.clear_all()
			
	if has_node("/root/EventBus"):
		EventBus.match_won.emit()
