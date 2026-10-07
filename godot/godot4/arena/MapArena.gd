extends Node2D

signal done

const DEFAULT_MINIGAME := preload("res://godot4/data/minigames/default.tres")

var session: Session
var _ships_spawned := false
var _level_started := false

func _ready() -> void:
	%ShipFactory.set_minigame(DEFAULT_MINIGAME)
	var current := get_tree().current_scene
	if session == null and current != null and (current == self or current.name == "MapScreen"):
		set_session(_fallback_session())

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
	var label := "time circuits"
	var circuits := %Battlefield.get_node_or_null("TimeCircuits") as Collectable
	if circuits != null and circuits.item != null and circuits.item.description != "":
		label = circuits.item.description
	Events.message.emit(label, Color(0.75, 0, 1), Vector2(280, -30), true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if _level_started or not body is Ship:
		return
	var levels = Utils.list_levels(1, 'pve')
	if levels.is_empty():
		return
	_level_started = true
	Events.level_selected.emit(levels[0]['scene'], [] as Array[String])
	done.emit()
