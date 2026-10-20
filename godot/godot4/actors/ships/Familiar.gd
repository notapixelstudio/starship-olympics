class_name Familiar extends RigidBody2D
## An item companion living on the battlefield, chained behind its [member leader]: the ship or the previous familiar.
## With no ship to lead the chain it coasts until ItemManager hands it the next one.
## Ship-like for its weapons and behaviours: it relays the ship's [signal tap], and team and color come from the player.

signal tap(charge: float)

## False for familiars that roam on their own: they still answer to the chain's ship, but nobody links behind them.
@export var chains := true
## Pushing force for movement behaviours; the TerrainManager sets it (lower on ice).
var thrust := 10000.0
## Global rotation kept every physics step, since the body's own rotation is locked.
var facing := 0.0
var player: Player
var leader: Node2D
var _ship: Ship
var _blown := false

func _ready() -> void:
	modulate = player.get_color()

## Readable name for logs: the scene, since copies get generated node names.
func describe() -> String:
	return scene_file_path.get_file().get_basename()

## The ship at the head of the chain, or null while it is down.
func get_owner_ship() -> Ship:
	var node = leader
	while is_instance_valid(node) and node is Familiar:
		node = node.leader
	return node if is_instance_valid(node) and node is Ship and not node.is_queued_for_deletion() else null

func _physics_process(_delta: float) -> void:
	var ship := get_owner_ship()
	if ship == null:
		set_constant_force(Vector2.ZERO) # coast; every frame, since a freed ship already compares equal to null
	if ship != _ship:
		if is_instance_valid(_ship):
			_ship.tap.disconnect(tap.emit)
		if ship != null:
			ship.tap.connect(tap.emit)
		_ship = ship
	var areas: Array = $TouchArea.get_overlapping_areas()
	$TerrainManager.process_overlappers(areas)
	# like the ship: drifting (sliding sideways to where it faces) on ice leaves a trail
	var drift := linear_velocity.project(Vector2.DOWN.rotated(facing))
	var drifting: bool = $TerrainManager.get_current_terrain() == &'ice' and drift.length() > Ship.MIN_DRIFT
	if drifting != $IceAutoTrail.active:
		$IceAutoTrail.start() if drifting else $IceAutoTrail.stop()
	var blown := not freeze and areas.any(func(area): return area is RepealField)
	if blown and not _blown:
		Events.log.emit("[b]%s[/b] blown by an explosion" % describe())
	_blown = blown

## Pushes toward [param point] along the navigation path around walls, easing off within [param slow_radius]
## so it settles there; on ice it slides past. Call it every physics frame while steering.
func steer_to(point: Vector2, slow_radius := 200.0) -> void:
	if _blown: # inside an explosion's repeal field: let it carry us instead of fighting it
		set_constant_force(Vector2.ZERO)
		return
	var agent: NavigationAgent2D = $NavigationAgent2D
	var map := agent.get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map) > 0: # a goal inside a wall would pin us against it
		point = NavigationServer2D.map_get_closest_point(map, point)
	if agent.target_position.distance_squared_to(point) > 1024.0: # repath only once the goal moved a bit
		agent.target_position = point
	var next := agent.get_next_path_position()
	if agent.is_navigation_finished(): # the path stops short (agent radius, off-mesh goal): finish straight
		next = point
	set_constant_force(global_position.direction_to(next) * thrust * minf(1.0, global_position.distance_to(point) / slow_radius))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.transform = Transform2D(facing, state.transform.origin)

func get_player() -> Player:
	return player

func get_color() -> Color:
	return player.get_color()

func get_team() -> String:
	return player.get_team()

func get_target_velocity() -> Vector2:
	return _ship.get_target_velocity() if is_instance_valid(_ship) else Vector2.ZERO
