tool
extends RotoPowerline
class_name PowerBattery

export var charge := 0.0 setget set_charge
export var charging_speed := 0.02
export var score_multiplier := 100.0

export var goal_owner : NodePath
var player

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		
func set_player(v : InfoPlayer):
	player = v
	$'%ChargePolygon'.modulate = player.species.color
	$'%BatteryOutline'.modulate = player.species.color
	$'%PlayerLabel'.text = player.get_username().to_upper()
	$'%PlayerLabel'.modulate = player.species.color
	
func get_player():
	return player

func set_charge(v: float) -> void:
	var capped_v = min(1.001, v) # exceed a bit to round nicely... (?)
	if player:
		global.the_match.add_score_to_team(player.team, (capped_v-charge)*score_multiplier)
	charge = capped_v
	
	if not is_inside_tree():
		yield(self, 'ready')
	
	$'%ChargePolygon'.polygon = PoolVector2Array([
		Vector2(-125, 200-charge*390-10),
		Vector2(125, 200-charge*390-10),
		Vector2(125, 200),
		Vector2(-125, 200)
	])

func _process(delta):
	if on:
		set_charge(charge+delta*charging_speed)
