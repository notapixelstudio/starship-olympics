extends Node
## Item effect registry: every items and its effects are written here, one entry per item id.
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
const BOUNTY := &"bounty"
const CHERRY := &"cherry"

# --- Effects: what each item does ---

## What each item does, by id. One line per item: its id and its whole effect.
var effects := {
	TIME_CIRCUITS: func(_holder): _add_time(15),
	CLOCK_EXTENDER: func(_holder): _add_time(5),
	HEAD_START: func(holder): _add_points(5, holder),
	BOUNTY: func(holder): # ceasefire: paid while at peace, the first hit ends it for this match
		var pay := _every(10.0, func(): if _holds(BOUNTY, holder): _add_points(1, holder))
		_when_down(holder, pay.stop),
	CHERRY: func(holder): _with_ship(holder, _duplicate),
}

## Merged id -> the ids it replaces (one copy of each part). A merged id has its own ItemType at data/items/<id>.tres.
var mergers := {
	CHERRY: [BOUNTY, HEAD_START],
}

# --- Building blocks effects use ---

func _add_time(seconds: int) -> void:
	%ArenaScope.time_gained.emit(seconds)

## Session copies score for every team, player copies for their player's team.
func _add_points(points: int, holder: String) -> void:
	var teams: Dictionary = %ArenaScope.get_teams()
	for team in teams:
		if holder == "" or holder in teams[team]:
			Events.points_scored.emit(float(points), team)

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

## True while [param id] is in play for [param holder]: carried, not shattered, not swallowed by a merger.
## per id, not per copy: with 2 Bounties and 1 merged mid-match, both Bounty timers keep paying. Track copies if that matters.
func _holds(id: StringName, holder: String) -> bool:
	return id in _in_play(holder)

## Player id -> actions waiting for their ship to enter the battlefield (at match start ships are not there yet).
var _waiting_for_ship := {}

## Calls [param action] with [param holder]'s ship: now if it is on the battlefield, else as soon as it enters.
func _with_ship(holder: String, action: Callable) -> void:
	var ships := _ships(holder)
	if ships:
		action.call(ships[0])
	else:
		_waiting_for_ship.get_or_add(holder, []).append(action)

# --- Item-specific actions ---

## One chain per player, led by its first ship. Cherry twin don't get that. Split chains per ship if twins need familiars.
func _sync_item_actors(holder: String) -> void:
	var wanted := {}
	for id in _in_play(holder):
		var scene: PackedScene = _type(id, holder).actor_scene
		if scene != null:
			wanted[scene.resource_path] = wanted.get(scene.resource_path, 0) + 1
	var chain := []
	for familiar in _familiars(holder):
		var path: String = familiar.scene_file_path
		if wanted.get(path, 0) > 0:
			wanted[path] -= 1
			chain.append(familiar)
		else:
			familiar.queue_free()
	var ships := _ships(holder).filter(func(ship): return not ship.is_queued_for_deletion())
	var ship: Ship = ships[0] if ships else null
	var spawned := []
	if ship != null: # missing copies wait for a ship to spawn at
		for path in wanted:
			for i in wanted[path]:
				var familiar := load(path).instantiate() as Familiar
				familiar.player = ship.get_player()
				familiar.global_position = ship.global_position
				spawned.append(familiar)
	chain.append_array(spawned)
	var leader: Node2D = ship
	for familiar in chain:
		familiar.leader = leader
		if familiar.chains:
			leader = familiar
		if ship != null:
			familiar.add_collision_exception_with(ship)
	for familiar in spawned:
		%Battlefield.add_child(familiar) # not spawn_request: that defers, and a second sync this frame would miss these
	var names := func(list: Array) -> String: return ", ".join(list.map(func(f): return f.describe()))
	var status := "%s familiars %s: chain [%s], free [%s]" % [holder, "follow the ship" if ship else "[b]coasting[/b] (no ship)", names.call(chain.filter(func(f): return f.chains)), names.call(chain.filter(func(f): return not f.chains))]
	if not chain.is_empty() and status != _logged_chains.get(holder):
		Events.log.emit(status)
	_logged_chains[holder] = status

## Holder -> last chain status logged, so repeated syncs stay quiet.
var _logged_chains := {}

func _familiars(holder: String) -> Array:
	return %Battlefield.get_children().filter(func(node): return node is Familiar and node.get_player().get_id() == holder and not node.is_queued_for_deletion())

## Like Super Mario cherry: a second ship for the same player, same controls.
## One hit and the twin is gone; the original ship respawns as usual.
func _duplicate(ship: Ship) -> void:
	var copy := ship.clone()
	copy.respawns = false
	copy.global_position = ship.global_position + Vector2(150, 0).rotated(ship.global_rotation + PI / 2)
	copy.global_rotation = ship.global_rotation
	%ArenaScope.spawn_request.emit(copy)

# --- How items run (no need to touch when adding an item) ---

func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.item_obtained, _on_item_obtained) \
		.bind(%ArenaScope.item_lost, _on_item_lost) \
		.bind(%ArenaScope.ship_down, _on_ship_down) \
		.bind(%ArenaScope.battlefield_ready, _print_carried) \
		.bind(%Battlefield.child_entered_tree, _on_battlefield_child_entered)

func _on_item_obtained(item:Item, by_player:Player) -> void:
	var session = %ArenaScope.get_current_session()
	if session == null:
		return
	var holder := "" if item.is_general() or by_player == null else by_player.get_id()
	if item in session.items.get(holder, []): # already held, e.g. a cargo carried into the match
		return
	var before := _in_play(holder)
	Events.log.emit('%s obtained item %s with id %d' % [holder, item, item.get_instance_id()])
	session.grant_item(item, holder)
	if _in_match():
		_start(_in_play(holder), before, holder)

func _on_item_lost(item:Item, by_player:Player) -> void:
	var session = %ArenaScope.get_current_session()
	if session == null:
		return
	Events.log.emit('%s lost item %s with id %d' % [by_player.get_id(), item, item.get_instance_id()])
	session.revoke_item(item, by_player.get_id())
	
func _on_ship_down(ship: Ship) -> void:
	var session = %ArenaScope.get_current_session()
	if session == null:
		return
	session.break_glass.call_deferred(ship.get_player().get_id()) # after the items' own reactions to this hit
	_sync_item_actors.call_deferred(ship.get_player().get_id())

## Applies every carried copy. [Arena] calls this once its teams are set up.
## TODO: This currently works ONLY with players and not with TEAMs 
func on_match_start() -> void:
	var session = %ArenaScope.get_current_session()
	if session == null:
		return
	for holder in session.items:
		_start(_in_play(holder), [], holder)
		for item in session.items[holder]:
			if item.is_cargo():
				_with_ship(holder, _load_cargo.bind(item))

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
	_sync_item_actors.call_deferred(holder)

## Cargo items (see [method ItemType.is_cargo]) have no effect: carried into a match, they are back on the ship.
## The cargo wraps the very [Item] the player holds, so loading it obtains nothing new.
func _load_cargo(ship: Ship, item: Item) -> void:
	var cargo := item.get_element_scene().instantiate() as Cargo
	cargo._self_scene = item.get_element_scene()
	cargo.item = item
	ship.load_cargo(cargo) # the ship keeps a clone
	cargo.free()


## One id per copy [param holder] carries, complete sets merged.
func _in_play(holder: String) -> Array:
	return merge(%ArenaScope.get_current_session().items.get(holder, []).map(func(item: Item) -> StringName: return item.get_type_id()), mergers)

## Replaces every complete set of parts in [param ids] with its merged id.
static func merge(ids: Array, merger_parts: Dictionary) -> Array:
	ids = ids.duplicate()
	for merged in merger_parts:
		while merger_parts[merged].all(func(part): return part in ids):
			for part in merger_parts[merged]:
				ids.erase(part)
			ids.append(merged)
	return ids

## Shows the badge of every item in play for the ship's player (called when items start and when a ship enters).
func _show_badges(ship: Ship) -> void:
	var holder := ship.get_player().get_id()
	ship.set_badges(_in_play(holder).map(func(id): return _type(id, holder).badge).filter(func(badge): return badge != null))

## The ItemType behind [param id]: a held item's, or the merged item's own file.
func _type(id: StringName, holder: String) -> ItemType:
	for item in %ArenaScope.get_current_session().items.get(holder, []):
		if item.get_type_id() == id:
			return item.type
	return load(ItemType.ITEMS_DIR + id + ".tres")

func _on_battlefield_child_entered(node: Node) -> void:
	if node is Ship:
		for action in _waiting_for_ship.get(node.get_player().get_id(), []):
			# WARNING: this is done in order to wait the Ship to be ready
			action.call_deferred(node)
		_waiting_for_ship.erase(node.get_player().get_id())
		_show_badges(node)
		_sync_item_actors.call_deferred(node.get_player().get_id())

func _print_carried() -> void:
	var session = %ArenaScope.get_current_session()
	if session == null:
		return
	print("items in play:")
	for holder in session.items:
		print("  %s: %s" % [holder if holder else "session", ", ".join(_in_play(holder))])

func _ships(holder: String) -> Array:
	return %Battlefield.get_children().filter(func(node): return node is Ship and node.get_player().get_id() == holder)

func _in_match() -> bool:
	return get_parent().get_parent() is Arena
