extends Arena
class_name PveArena
## An Arena scene for the Pve game mode (either single player or co-op).

@export var medals : Medals

func _ready():
	super._ready()
	Events.ship_captured.connect(_on_ship_captured)

func setup() -> void:
	super()
	%ScoreHUD.set_thresholds([
		{'value': _params.bronze, 'image': medals.bronze},
		{'value': _params.silver, 'image': medals.silver},
		{'value': _params.gold, 'image': medals.gold},
	])
	%ScoreManager.set_thresholds([_params.bronze, _params.silver, _params.gold])
	
func setup_team(team:String) -> void:
	super(team)
	
func _update_session(data:Dictionary) -> void:
	# FIXME this logic could maybe better placed in Session
	data['medal'] = ''
	for standing in data['standings']:
		if int(standing['score']) >= _params.gold:
			data['medal'] = 'gold'
		elif int(standing['score']) >= _params.silver:
			data['medal'] = 'silver'
		elif int(standing['score']) >= _params.bronze:
			data['medal'] = 'bronze'
	super(data)

func _on_ship_captured(ship:Ship, trap) -> void:
	if trap is ShipBubble:
		if len(get_active_players()) > 1:
			# end the game if all ships have been captured
			await get_tree().process_frame
			if get_tree().get_node_count_in_group('Ship') == 0:
				await get_tree().create_timer(1).timeout
				Events.force_match_over.emit("No players left")
		else:
			# if we are playing solo, automatically pop the bubble after a while
			trap.set_auto_popping(true)
