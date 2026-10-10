extends Node
## Effect registry: everything carried items do during a match is written here, one entry per item id.
## Items stay plain data, so an effect can read the whole inventory and combine with other items, e.g.
## [code]CLOCK_EXTENDER: func(_holder): _add_time(5 * (2 if _session().count_items(TIME_CIRCUITS) else 1))[/code]
##
## An effect runs for one copy held by [param holder] (a player id, or [code]""[/code] for the whole session):
## immediately when it is picked up during a match, and at the start of every match it is carried into.
## Outside a match (e.g. MapArena) a pickup is only carried.
##
## [member mergers]: when one holder carries every part, the merged id runs instead of its parts
## (at match start, or as soon as a pickup completes the set).

const TIME_CIRCUITS := &"time-circuits"
const CLOCK_EXTENDER := &"clock_extender"
const HEAD_START := &"starting_points"
const BASKET_BALL := &"basket_ball"
const BOUNTY := &"bounty"
const CHERRY := &"cherry"

const BASKET_BALL_SCENE := preload("res://godot4/elements/cargos/BasketBall.tscn")

## What each item does, by id. One line per item: its id and its whole effect.
var effects := {
	TIME_CIRCUITS: func(_holder): _add_time(15),
	CLOCK_EXTENDER: func(_holder): _add_time(5),
	HEAD_START: func(holder): _add_points(5, holder),
	BASKET_BALL: func(holder): _with_ship(holder, _load_ball),
	BOUNTY: func(holder): # ceasefire: paid while at peace, the first hit ends it for this match
		var pay := _every(10.0, func(): if _holds(BOUNTY, holder): _add_points(1, holder))
		_when_down(holder, pay.stop),
	CHERRY: func(holder): _with_ship(holder, _duplicate),
}

## Merged id -> the ids it replaces (one copy of each part). A merged id has its own ItemType at data/items/<id>.tres.
var mergers := {
	CHERRY: [BOUNTY, HEAD_START],
}

## Player id -> actions waiting for their ship to enter the battlefield (at match start ships are not there yet).
var _waiting_for_ship := {}

func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.item_obtained, _on_item_obtained) \
		.bind(%ArenaScope.ship_down, _on_ship_down) \
		.bind(%ArenaScope.battlefield_ready, _print_carried) \
		.bind(%Battlefield.child_entered_tree, _on_battlefield_child_entered)

func _on_item_obtained(item:Item, by_player:Player) -> void:
	var session := _session()
	if session == null:
		return
	var holder := "" if item.is_general() or by_player == null else by_player.get_id()
	var before := _in_play(holder)
	session.grant_item(item, holder)
	if _in_match():
		_start(_in_play(holder), before, holder)

func _on_ship_down(ship: Ship) -> void:
	var session := _session()
	if session == null:
		return
	session.break_glass.call_deferred(ship.get_player().get_id()) # after the items' own reactions to this hit

## Applies every carried copy. [Arena] calls this once its teams are set up.
## TODO: This currently works ONLY with players and not with TEAMs 
func on_match_start() -> void:
	var session := _session()
	if session == null:
		return
	for holder in session.items:
		_start(_in_play(holder), [], holder)

## Runs the effects of the ids in [param now] that were not already in [param before].
## Parts swallowed by a merger stop on their own: their timers and reactions check [method _holds].
func _start(now: Array, before: Array, holder: String) -> void:
	for id in before:
		now.erase(id)
	for id in now:
		if effects.has(id):
			effects[id].call(holder)
	for ship in _ships(holder):
		_show_badges(ship)

## One id per copy [param holder] carries, complete sets merged.
func _in_play(holder: String) -> Array:
	return merge(_session().items.get(holder, []).map(func(item: Item) -> StringName: return item.id), mergers)

## Replaces every complete set of parts in [param ids] with its merged id.
static func merge(ids: Array, merger_parts: Dictionary) -> Array:
	ids = ids.duplicate()
	for merged in merger_parts:
		while merger_parts[merged].all(func(part): return part in ids):
			for part in merger_parts[merged]:
				ids.erase(part)
			ids.append(merged)
	return ids

## True while [param id] is in play for [param holder]: carried, not shattered, not swallowed by a merger.
## ponytail: per id, not per copy: with 2 Bounties and 1 merged mid-match, both Bounty timers keep paying. Track copies if that matters.
func _holds(id: StringName, holder: String) -> bool:
	return id in _in_play(holder)

## Runs [param tick] every [param seconds] until the match ends (the timer is freed with the arena) or it is stopped.
func _every(seconds: float, tick: Callable) -> Timer:
	var timer := Timer.new()
	timer.wait_time = seconds
	timer.timeout.connect(tick)
	add_child(timer)
	timer.start()
	return timer

## Runs [param reaction] each time [param holder]'s ship goes down (disabled or killed), until the match ends.
func _when_down(holder: String, reaction: Callable) -> void:
	%ArenaScope.ship_down.connect(func(ship: Ship): if ship.get_player().get_id() == holder: reaction.call())

func _add_time(seconds: int) -> void:
	%ArenaScope.time_gained.emit(seconds)

## Session copies score for every team, player copies for their player's team.
func _add_points(points: int, holder: String) -> void:
	var teams: Dictionary = %ArenaScope.get_teams()
	for team in teams:
		if holder == "" or holder in teams[team]:
			Events.points_scored.emit(float(points), team)

## Calls [param action] with [param holder]'s ship: now if it is on the battlefield, else as soon as it enters.
func _with_ship(holder: String, action: Callable) -> void:
	var ships := _ships(holder)
	if ships:
		action.call(ships[0])
	else:
		_waiting_for_ship.get_or_add(holder, []).append(action)

func _ships(holder: String) -> Array:
	return %Battlefield.get_children().filter(func(node): return node is Ship and node.get_player().get_id() == holder)

## Shows the badge of every item in play for the ship's player (called when items start and when a ship enters).
func _show_badges(ship: Ship) -> void:
	var holder := ship.get_player().get_id()
	ship.set_badges(_in_play(holder).map(func(id): return _type(id, holder).badge).filter(func(badge): return badge != null))

## The ItemType behind [param id]: a held item's, or the merged item's own file.
func _type(id: StringName, holder: String) -> ItemType:
	for item in _session().items.get(holder, []):
		if item.id == id:
			return item.type
	return load(ItemType.ITEMS_DIR + id + ".tres")

func _on_battlefield_child_entered(node: Node) -> void:
	if node is Ship:
		for action in _waiting_for_ship.get(node.get_player().get_id(), []):
			action.call(node)
		_waiting_for_ship.erase(node.get_player().get_id())
		_show_badges(node)

func _load_ball(ship: Ship) -> void:
	var ball := BASKET_BALL_SCENE.instantiate() as Cargo
	ball._self_scene = BASKET_BALL_SCENE # a Cargo packs itself in _ready, but this one never enters the tree
	ship.load_cargo(ball) # the ship keeps a clone
	ball.free()

## Like the Super Mario cherry: a second ship for the same player, same controls.
## One hit and the twin is gone for good; the original ship respawns as usual.
func _duplicate(ship: Ship) -> void:
	var copy := ship.clone()
	copy.respawns = false
	copy.global_position = ship.global_position + Vector2(150, 0).rotated(ship.global_rotation + PI / 2)
	copy.global_rotation = ship.global_rotation
	%ArenaScope.spawn_request.emit(copy)

func _print_carried() -> void:
	var session := _session()
	if session == null:
		return
	print("items in play")
	for holder in session.items:
		print("  %s: %s" % [holder if holder else "session", ", ".join(_in_play(holder))])

func _in_match() -> bool:
	return get_parent().get_parent() is Arena

func _session() -> Session:
	var arena := get_parent().get_parent()
	if arena == null or not "session" in arena:
		return null
	return arena.session
