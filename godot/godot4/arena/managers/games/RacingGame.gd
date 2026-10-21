extends Node

const BATON_SCENE := preload("res://godot4/elements/cargos/Baton.tscn")
const WALL_SCENE := preload("res://godot4/elements/walls/Wall.tscn")

const MSG_PASS_IT := "PASS IT!"
const FLASH_DURATION := 1.5
const FLASH_COLOR := Color(1, 0.85, 0.2)

const PEN_HALF_EXTENT := 320.0 # roomy enough for 3p/4p teams too, where more than one teammate may be benched here
const PEN_WALL_THICKNESS := 40.0
const PEN_DOOR_SIDE := Vector2.DOWN # faces back down toward the course, out of the pen's tucked-away corner

@onready var _ctx := ArenaScope.get_scope(self)

var _ordered_gates : Array
var _progress : Dictionary # team_id(String): gate_index(int)
var _relay_teams : Dictionary # team_id(String): true -- teams with 2+ players carry a relay baton
var _pending_baton : Dictionary # player_id(String): true -- waiting for this player's ship to enter the battlefield
var _lap_started : Dictionary # team_id(String): true -- the team has crossed the start gate at least once
var _pen_doors : Dictionary # team_id(String): Wall -- the one wall segment that opens up the benched teammate's starting pen

func _ready() -> void:
	_ordered_gates = %Course.get_children()

	for gate in _ordered_gates:
		gate.crossed.connect(_on_gate_crossed)

	%Battlefield.child_entered_tree.connect(_on_battlefield_child_entered)

	await _ctx.battlefield_ready

	for team in _ctx.get_teams():
		_progress[team] = 0
		var teammates := _ctx.get_active_players().filter(func(p): return p.get_team() == team)
		if len(teammates) > 1:
			_relay_teams[team] = true
			_give_baton_to(teammates[0])
			for benched in teammates.slice(1):
				_build_pen(benched, team)

	for player in _ctx.get_active_players():
		_ordered_gates[0].add_target(player)

func _give_baton_to(player:Player) -> void:
	var ship := _find_ship(player)
	if ship:
		_load_baton(ship)
	else:
		# the ship isn't on the battlefield yet (player hasn't readied up) - catch it when it arrives
		_pending_baton[player.get_id()] = true

func _find_ship(player:Player) -> Ship:
	for ship in get_tree().get_nodes_in_group('Ship'):
		if ship.get_player() == player:
			return ship
	return null

func _home_position(player:Player) -> Vector2:
	var index := _ctx.get_active_players().find(player)
	return %Homes.get_children()[index].global_position

## Boxes a benched teammate in at the start, so it's obvious they're waiting their turn rather than free to roam.
## Three sides are permanent; the door side is freed once their team's baton becomes passable.
func _build_pen(player:Player, team:String) -> void:
	var center := _home_position(player)
	for side in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var wall : Wall = WALL_SCENE.instantiate()
		%Battlefield.add_child(wall)
		wall.position = center + side * PEN_HALF_EXTENT
		var horizontal := absf(side.y) > 0.5 # top/bottom walls run wide in X; left/right walls run wide in Y
		var reach := Vector2(PEN_HALF_EXTENT, PEN_WALL_THICKNESS) if horizontal else Vector2(PEN_WALL_THICKNESS, PEN_HALF_EXTENT)
		wall.set_polygon(PackedVector2Array([-reach, Vector2(reach.x, -reach.y), reach, Vector2(-reach.x, reach.y)]))
		if side == PEN_DOOR_SIDE:
			_pen_doors[team] = wall

func _open_pen(team:String) -> void:
	if _pen_doors.has(team):
		_pen_doors[team].queue_free()
		_pen_doors.erase(team)

func _on_battlefield_child_entered(node: Node) -> void:
	if not node is Ship:
		return
	var ship : Ship = node
	var player := ship.get_player()
	if _pending_baton.get(player.get_id(), false):
		_pending_baton.erase(player.get_id())
		_load_baton(ship)

func _load_baton(ship: Ship) -> void:
	var baton := BATON_SCENE.instantiate() as Cargo
	baton._self_scene = BATON_SCENE # a Cargo packs itself in _ready, but this one never enters the tree
	ship.load_cargo(baton)
	baton.free()

## Briefly calls out that the baton is ready to be handed off, then clears itself - no persistent nagging.
func _flash_handoff_prompt(by_what: Ship) -> void:
	by_what.set_message(MSG_PASS_IT, FLASH_COLOR)
	get_tree().create_timer(FLASH_DURATION).timeout.connect(func(): by_what.set_message(""))

func _on_gate_crossed(by_what, gate:Gate, trigger:bool) -> void:
	if not (by_what is Ship):
		return

	var player = by_what.get_player()
	var team = player.get_team()

	if _relay_teams.get(team, false):
		if not by_what.has_cargo_class(Baton):
			return # only the baton carrier's crossings advance the shared progress
		if by_what.get_cargo_manager().get_cargo().passable:
			return # this carrier already finished a lap - must hand the baton off before scoring again

	Events.log.emit('Gate crossed')
	if gate == _ordered_gates[_progress[team]]:
		# crossing the start gate again (not for the first time) means a lap is complete
		var lap_completed : bool = gate == _ordered_gates[0] and _lap_started.get(team, false)
		# crossing the gate right before the start: release the teammate early so they're already
		# moving when the lap finishes, like a real relay exchange zone - not standing still for it
		var final_stretch : bool = gate == _ordered_gates[-1]
		_lap_started[team] = true

		_progress[team] = (_progress[team] + 1) % len(_ordered_gates)
		Events.score.emit(1, player, by_what.global_position)
		Events.log.emit('Gate %s passed: next is %s (number %d)' % [gate.name, _ordered_gates[_progress[team]].name, _progress[team]])
		gate.show_feedback()

		if _relay_teams.get(team, false) and final_stretch:
			_open_pen(team)

		if lap_completed and _relay_teams.get(team, false):
			by_what.get_cargo_manager().get_cargo().passable = true
			by_what.get_cargo_manager().mark_baton_passable()
			gate.pulse_unlocked()
			_flash_handoff_prompt(by_what)

		# update next gate feedback for every teammate
		for teammate in _ctx.get_active_players():
			if teammate.get_team() == team:
				gate.remove_target(teammate)
				_ordered_gates[_progress[team]].add_target(teammate)
	else:
		# bad gate passed
		_ctx.player_failed.emit(player)
		gate.show_feedback_bad()
