extends Node2D

@export var players : Dictionary # String: Player
@export var ship_scene : PackedScene
@export var player_brain_scene : PackedScene
@export var cpu_brain_scene : PackedScene
@export var match_over_screen_scene : PackedScene
@export var default_minigame : Minigame
@export var default_params : MatchParams

var _params : MatchParams

func _ready() -> void:
	var minigame = get_minigame()
	_params = get_match_params()
	
	%MinigameText.text = '[right][color=#ffde5e]%s[/color]\n%s[/right]' % [minigame.title.to_upper(), minigame.description.to_upper()]
	%MinigameIcon.texture = minigame.icon
	
	%TimeManager.set_time(_params.time)
	%Clock.set_value(_params.time)
	%TimeBar.set_max_value(_params.time)
	%TimeBar.set_value(0.0) # time always starts from 0
	Events.clock_ticked.connect(_on_clock_ticked)
	
	%VersusGameOverManager.set_max_score(_params.score)
	
	var match_over_screen = match_over_screen_scene.instantiate()
	%HUD.add_child(match_over_screen)
	Events.match_over.connect(_on_match_over)
	
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
		
		if minigame.starting_weapon:
			var weapon = minigame.starting_weapon.instantiate()
			ship.add_child(weapon)
		
		%Battlefield.add_child(ship)
		
		if player.get_team() not in teams:
			teams[player.get_team()] = []
		teams[player.get_team()].append(player.get_id())
	
	for team in teams.keys():
		%ScoreManager.add_team(team)
		%VersusHUD.set_max_score(_params.score)
		%VersusHUD.set_starting_score(_params.starting_score)
		%VersusHUD.add_team(team, players[teams[team][0]].get_species()) # FIXME support teams of 2+ members

func get_id() -> String:
	return get_tree().current_scene.scene_file_path.get_file().split('.')[0]
	
func get_minigame_id() -> String:
	return get_id().split('_')[0]
	
func get_minigame() -> Minigame:
	var minigame_resource_path = 'res://godot4/data/minigames/'+get_minigame_id()+'.tres'
	if not ResourceLoader.exists(minigame_resource_path):
		return default_minigame
	return load(minigame_resource_path)
	
func get_match_params() -> MatchParams:
	var params_resource_path = 'res://godot4/data/match_params/'+get_id()+'.tres'
	if not ResourceLoader.exists(params_resource_path):
		return default_params
	return load(params_resource_path)
	
	
func _on_clock_ticked(t:float, t_secs:int) -> void:
	%Clock.set_value(t_secs)
	%TimeBar.set_value(_params.time - t)

func _on_match_over(data:Dictionary) -> void:
	# peform a match over animation
	var tween = get_tree().create_tween()
	#tween.set_parallel()
	tween.tween_property(Engine, "time_scale", 0.1, 0.6).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property($Battlefield, "modulate", Color(0.7,0.7,0.7), 0.6).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_match_over_anim_finished)

func _on_match_over_anim_finished() -> void:
	get_tree().paused = true
	Engine.time_scale = 1
	Events.match_over_anim_ended.emit()

func _unhandled_key_input(event) -> void:
	if OS.is_debug_build():
		# cause the clock to expire for testing
		if event.is_action_pressed("debug_action"):
			Events.clock_expired.emit()
			
		# reset the current level
		if event.is_action_pressed("debug_restart_scene"):
			get_tree().reload_current_scene()
