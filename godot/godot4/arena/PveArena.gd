extends Arena
class_name PveArena
## An Arena scene for the Pve game mode (either single player or co-op).

@export var medals : Medals

func setup() -> void:
	super()
	%ScoreHUD.set_thresholds([
		{'value': _params.bronze, 'image': medals.bronze},
		{'value': _params.silver, 'image': medals.silver},
		{'value': _params.gold, 'image': medals.gold},
	])
	
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
