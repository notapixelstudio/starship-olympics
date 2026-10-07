extends Node
## Effect registry: everything carried items do during a match is written here, one entry per item id.
## Items stay plain data, so an effect can read the whole inventory and combine with other items, e.g.
## [code]CLOCK_EXTENDER: func(_holder): _add_time(5 * (2 if _session().count_items(TIME_CIRCUITS) else 1))[/code]
##
## An effect runs for one copy held by [param holder] (a player id, or [code]""[/code] for the whole session):
## immediately when it is picked up during a match, and at the start of every match it is carried into.
## Outside a match (e.g. MapArena) a pickup is only carried.

const TIME_CIRCUITS := &"time-circuits"
const CLOCK_EXTENDER := &"clock_extender"
const HEAD_START := &"starting_points"
const BASKET_BALL := &"basket_ball"

const BASKET_BALL_SCENE := preload("res://godot4/elements/cargos/BasketBall.tscn")

## What each item does, by id. One line per item: its id and its whole effect.
var effects := {
	TIME_CIRCUITS: func(_holder): _add_time(15),
	CLOCK_EXTENDER: func(_holder): _add_time(5),
	HEAD_START: func(holder): _add_points(5, holder),
	BASKET_BALL: func(holder): _give_ball(holder),
}

## Player ids whose ship gets a ball as soon as it enters the battlefield (at match start ships are not there yet).
var _waiting_for_ball: Array[String] = []

func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.item_obtained, _on_item_obtained) \
		.bind(%ArenaScope.battlefield_ready, _print_carried) \
		.bind(%Battlefield.child_entered_tree, _on_battlefield_child_entered)

func _on_item_obtained(item:Item, by_player:Player) -> void:
	var session := _session()
	if session == null:
		return
	var holder := "" if item.is_general() or by_player == null else by_player.get_id()
	session.grant_item(item, holder)
	if _in_match():
		_apply(item, holder)

## Applies every carried copy. [Arena] calls this once its teams are set up.
## TODO: This currently works ONLY with players and not with TEAMs 
func on_match_start() -> void:
	var session := _session()
	if session == null:
		return
	for holder in session.items:
		for item in session.items[holder]:
			_apply(item, holder)

func _apply(item: Item, holder: String) -> void:
	if effects.has(item.id):
		effects[item.id].call(holder)

func _add_time(seconds: int) -> void:
	%ArenaScope.time_gained.emit(seconds)

## Session copies score for every team, player copies for their player's team.
func _add_points(points: int, holder: String) -> void:
	var teams: Dictionary = %ArenaScope.get_teams()
	for team in teams:
		if holder == "" or holder in teams[team]:
			Events.points_scored.emit(float(points), team)

## The holder's ship carries a ball, ready to be kicked.
func _give_ball(holder: String) -> void:
	for node in %Battlefield.get_children():
		if node is Ship and node.get_player().get_id() == holder:
			_load_ball(node)
			return
	_waiting_for_ball.append(holder)

func _on_battlefield_child_entered(node: Node) -> void:
	if node is Ship and node.get_player().get_id() in _waiting_for_ball:
		_waiting_for_ball.erase(node.get_player().get_id())
		_load_ball(node)

func _load_ball(ship: Ship) -> void:
	var ball := BASKET_BALL_SCENE.instantiate() as Cargo
	ball._self_scene = BASKET_BALL_SCENE # a Cargo packs itself in _ready, but this one never enters the tree
	ship.load_cargo(ball) # the ship keeps a clone
	ball.free()

func _print_carried() -> void:
	var session := _session()
	if session == null:
		return
	for holder in session.items:
		for item in session.items[holder]:
			print("item: %s | owner: %s" % [item.name, holder if holder else "session"])

func _in_match() -> bool:
	return get_parent().get_parent() is Arena

func _session() -> Session:
	var arena := get_parent().get_parent()
	if arena == null or not "session" in arena:
		return null
	return arena.session
