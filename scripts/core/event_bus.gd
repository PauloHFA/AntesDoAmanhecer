class_name EventBusNode
extends Node

## Barramento central de eventos do jogo (Autoload: EventBus)
## Desacopla sistemas de combate, entidades, HUD e progressão.

# --- Eventos do Jogador ---
signal player_damaged(current_hp: int, max_hp: int)
signal player_healed(current_hp: int, max_hp: int)
signal player_died
signal fury_changed(current_fury: float, max_fury: float)
signal fury_activated(duration: float)

# --- Eventos de Progressão e Nível ---
signal xp_collected(amount: int, current_xp: int, target_xp: int)
signal level_up_triggered(new_level: int)
signal power_card_selected(power_id: String)
signal gold_collected(amount: int, total_gold: int)

# --- Eventos de Inimigos e Hordas ---
signal enemy_killed(enemy_type: String, death_position: Vector2, gives_gem: bool)
signal kill_count_milestone_reached(milestone: int)
signal boss_spawned(boss_name: String)
signal boss_defeated(boss_name: String)

# --- Eventos de Estado de Partida ---
signal game_paused(is_paused: bool)
signal match_won
signal match_lost
signal night_clock_updated(time_remaining_seconds: float)
