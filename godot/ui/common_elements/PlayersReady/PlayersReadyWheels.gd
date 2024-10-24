extends HBoxContainer

@export var player_ready_wheel_scene : PackedScene
@export var players : Array[Player] : set = set_players

func set_players(v:Array[Player]) -> void:
	players = v
	
	if not is_inside_tree():
		await self.ready
		
	# empty container
	for child in get_children():
		child.queue_free()
		
	var i := 0
	for player in players:
		var player_ready_wheel = player_ready_wheel_scene.instantiate()
		player_ready_wheel.set_player(player)
		add_child(player_ready_wheel)
		
