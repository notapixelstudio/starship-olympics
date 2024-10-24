extends HBoxContainer

@export var player_ready_wheel_scene : PackedScene
@export var players : Array[Player] : set = set_players

signal all_players_ready

var _players_ready := {}

func set_players(v:Array[Player]) -> void:
	players = v
	
	_players_ready = {}
	for player in players:
		_players_ready[player.get_id()] = false
		
	
	if not is_inside_tree():
		await self.ready
		
	# empty container
	for child in get_children():
		child.queue_free()
		
	var i := 0
	for player in players:
		var player_ready_wheel = player_ready_wheel_scene.instantiate()
		player_ready_wheel.set_player(player)
		player_ready_wheel.player_ready.connect(self._on_player_ready)
		add_child(player_ready_wheel)
		
func _on_player_ready(player:Player) -> void:
	_players_ready[player.get_id()] = true
	for is_player_ready in _players_ready.values():
		if not is_player_ready:
			return
	all_players_ready.emit()
	queue_free()
