extends Node

var _royal_players: Array[Player] = []

func _ready():
	Events.match_over.connect(_on_match_over)
	Events.sth_loaded.connect(_on_sth_loaded)
	Events.sth_unloaded.connect(_on_sth_unloaded)
	
func _on_sth_loaded(loader, loadee):
	if loadee is Crown:
		_royal_players.append(loader.get_player())
	
func _on_sth_unloaded(unloader, unloadee):
	if unloadee is Crown:
		_royal_players.erase(unloader.get_player())
	
func _physics_process(delta: float) -> void:
	# assign points
	for royal_player in _royal_players:
		Events.points_scored.emit(delta, royal_player.get_team())
	
func _on_match_over(data:Dictionary) -> void:
	set_physics_process(false)
	if Events.sth_loaded.is_connected(_on_sth_loaded):
		Events.sth_loaded.disconnect(_on_sth_loaded)
