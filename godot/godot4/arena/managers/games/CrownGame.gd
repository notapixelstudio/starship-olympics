extends Node

var _royal_players: Array[Player] = []

func _ready():
	Events.match_over.connect(_on_match_over)
	Events.sth_loaded.connect(_on_sth_loaded)
	
func _on_sth_loaded(loader, loadee):
	_royal_players.append(loader.get_player())
	
func _physics_process(delta: float) -> void:
	# assign points
	for royal_player in _royal_players:
		Events.points_scored.emit(delta, royal_player.get_team())
	
func _on_match_over(data:Dictionary) -> void:
	set_physics_process(false)
	if Events.sth_loaded.is_connected(_on_sth_loaded):
		Events.sth_loaded.disconnect(_on_sth_loaded)
