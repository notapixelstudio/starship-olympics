extends Node
## Skip the ready screen so F6 opens a playable item test immediately.

func _ready() -> void:
	var battlefield := get_parent().get_node("Battlefield")
	for child in battlefield.get_children():
		if child.is_in_group("obstacle") and child.name not in ["OutsideWall", "CentralWall"]:
			child.queue_free()
	_start.call_deferred()

func _start() -> void:
	var arena := get_parent() as Arena
	for player in arena.get_active_players():
		Events.player_ready.emit(player)
	arena.get_node("%PlayersReadyWheels").hide()
	Events.battle_start.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_restart_scene") and not event.is_echo():
		get_tree().reload_current_scene()
