extends Node
## Effect registry: everything carried items do during a match is written here, keyed by item id.
## Items stay plain data, so an effect can read the whole inventory and combine with other items
## (e.g. "time circuits doubles clock extender pickups" is one line in [method _on_item_obtained]).

const TIME_CIRCUITS := &"time-circuits"
const CLOCK_EXTENDER := &"clock_extender"
const HEAD_START := &"starting_points"

func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.item_obtained, _on_item_obtained)

func _on_item_obtained(item:Item, by_player:Player) -> void:
	var session := _session()
	if session == null:
		return
	session.grant_item(item, "" if item.is_general() or by_player == null else by_player.get_id())

	match item.id:
		CLOCK_EXTENDER:
			%ArenaScope.time_gained.emit(5)

## Seconds carried items add to the clock at the start of the match.
func opening_seconds(session: Session) -> int:
	if session == null:
		return 0
	return 15 * session.count_items(TIME_CIRCUITS)

## Points carried items give each team at the start of the match, as team -> points.
## Session copies count once per team, player copies once for their player's team.
func opening_points(session: Session, players: Array) -> Dictionary:
	var points := {}
	if session == null:
		return points
	for player in players:
		var team: String = player.get_team()
		if not points.has(team):
			points[team] = 5 * session.count_items(HEAD_START, "")
		points[team] += 5 * session.count_items(HEAD_START, player.get_id())
	return points

func apply_opening_scores(players: Array) -> void:
	var points := opening_points(_session(), players)
	for team in points:
		if points[team] > 0:
			Events.points_scored.emit(float(points[team]), team)

## Adds the clock bonus of carried items. Returns the seconds added.
func apply_opening_time() -> int:
	var seconds := opening_seconds(_session())
	if seconds > 0:
		%ArenaScope.time_gained.emit(seconds)
	return seconds

func _session() -> Session:
	var arena := get_parent().get_parent()
	if arena == null or not "session" in arena:
		return null
	return arena.session
