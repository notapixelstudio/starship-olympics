extends Arena
class_name PveArena
## An Arena scene for the Pve game mode (either single player or co-op).

@export var medals_textures : Array[Texture] = []

func setup() -> void:
	super()
	%ScoreHUD.set_thresholds([
		{'value': _params.bronze, 'image': medals_textures[0]},
		{'value': _params.silver, 'image': medals_textures[1]},
		{'value': _params.gold, 'image': medals_textures[2]},
	])
	
func setup_team(team:String) -> void:
	super(team)
	
