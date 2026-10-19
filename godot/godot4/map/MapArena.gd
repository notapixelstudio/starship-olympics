extends Arena

signal done

const DEFAULT_MINIGAME := preload("res://godot4/data/minigames/default.tres")

var _ships_spawned := false

func _ready() -> void:
	%ShipFactory.set_minigame(DEFAULT_MINIGAME)
	var current := get_tree().current_scene
	if session == null and current != null and (current == self or current.name == "MapScreen"):
		set_session(_fallback_session())
		
	for level_start in %Levels.get_children():
		level_start.tapped.connect(_on_level_start_tapped.bind(level_start))

func set_session(value: Session) -> void:
	session = value
	if is_node_ready():
		_spawn_ships()

func _fallback_session() -> Session:
	var fallback := SinglePveMatchSession.new()
	var player: Player = (load("res://godot4/debug/default_data/default_players/p1.tres") as Player).duplicate() as Player
	player.set_team("GG")
	fallback.players = [player]
	return fallback

func _spawn_ships() -> void:
	if _ships_spawned or session == null or session.players.is_empty():
		return
	if %Homes.get_child_count() == 0:
		return
	_ships_spawned = true
	for i in session.players.size():
		var home := %Homes.get_child(mini(i, %Homes.get_child_count() - 1)) as Node2D
		var ship: Ship = %ShipFactory.create(session.players[i], true)
		%Battlefield.add_child(ship)
		ship.global_position = home.global_position

func _on_level_start_tapped(ship: Node2D, strength: float, level_start) -> void:
	if not ship is Ship:
		return
		
	var mode = 'pve'
	var minigame = level_start.get_minigame()
	var modifiers = level_start.get_modifiers()
	
	var level := Utils.level_path(minigame.get_id(), mode, session.players.size()) # the scene made for this many players
	if not ResourceLoader.exists(level):
		push_warning("no %s %s level for %d players" % [minigame, mode, session.players.size()])
		Events.message.emit("NO %dP LEVEL" % session.players.size(), ship.get_color(), ship.global_position)
		return
	Events.level_selected.emit(load(level), modifiers)
	done.emit()
