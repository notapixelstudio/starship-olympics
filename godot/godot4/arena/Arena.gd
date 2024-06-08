extends Node2D

@export var players : Dictionary # String: Player
@export var ship_scene : PackedScene
@export var player_brain_scene : PackedScene
@export var cpu_brain_scene : PackedScene

func _ready() -> void:
	var params = get_match_params()
	
	var teams := {}
	
	for home in %Homes.get_children():
		home.visible = false
		
		if home.name not in players:
			continue
			
		var player = players[home.name] as Player
		
		var ship = ship_scene.instantiate()
		ship.set_player(player)
		ship.global_rotation = home.global_rotation
		ship.global_position = home.global_position
		
		var brain
		if player.is_cpu():
			brain = cpu_brain_scene.instantiate()
		else:
			brain = player_brain_scene.instantiate()
			brain.set_controls(player.get_controls())
		ship.add_child(brain)
		
		%Battlefield.add_child(ship)
		
		if player.get_team() not in teams:
			teams[player.get_team()] = []
		teams[player.get_team()].append(player.get_id())
	
	for team in teams.keys():
		%ScoreManager.add_team(team)
		%VersusHUD.set_max_score(params.score)
		%VersusHUD.add_team(team, players[teams[team][0]].get_species()) # FIXME support teams of 2+ members

func get_id() -> String:
	return get_tree().current_scene.scene_file_path.get_file().split('.')[0]
	
func get_match_params() -> MatchParams:
	return load('res://godot4/data/match_params/'+get_id()+'.tres')
