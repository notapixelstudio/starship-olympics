extends Node2D
class_name Arena
## Base class for Arena scenes, responsible for managing the overall logic of a single match.
## It acts as a central hub for various components such as players, ships, and game modes.
## This class is considered an abstract class and should not be used directly.
## Instead, you should inherit from it and implement the necessary methods to handle a specific game logic.
##
## The Battlefield node is meant to contain the actual game elements such as collectables, enemies, and other game objects.
## The Homes node is meant to contain the starting positions of the players.
## Nodes under the HUD canvas layer are meant to be used for UI elements, such as the countdown timer, the match over screen, and the score bars.

@export var players : Array[Player]
@export var ship_scene : PackedScene
@export var player_brain_scene : PackedScene
@export var cpu_brain_scene : PackedScene
@export var match_over_screen_scene : PackedScene
@export var default_minigame : Minigame
@export var default_params : MatchParams
@export var session : Session

var _params : MatchParams
var _active_players : Array[Player] = []
var _teams := {}
var _players_by_id : Dictionary[String,Player] = {}

var _match_over_screen

func _ready() -> void:
	for player in players:
		_players_by_id[player.get_id()] = player
	
	var minigame = get_minigame()
	_params = get_match_params()
	
	%MinigameText.text = '[right][color=#ffde5e]%s[/color]\n%s[/right]' % [minigame.title.to_upper(), minigame.description.to_upper()]
	%MinigameIcon.texture = minigame.icon
	%PauseOverlay.set_minigame(minigame)
	
	setup()
	
	Events.clock_ticked.connect(_on_clock_ticked)
	Events.match_over.connect(_on_match_over)
	
	var brains_to_enable : Array[Brain] = []
	
	var i = 0
	for home in %Homes.get_children():
		home.visible = false
		
		var player = players[i] as Player
		_active_players.append(player)
		
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
		brain.enabled = false
		brains_to_enable.append(brain)
		ship.add_child(brain)
		
		if minigame.starting_weapon:
			var weapon = minigame.starting_weapon.instantiate()
			ship.add_child(weapon)
		
		# add ship as soon as the player is ready
		Events.player_ready.connect(func(p):
			if p == ship.get_player():
				%Battlefield.add_child(ship)
		)
		
		if player.get_team() not in _teams:
			_teams[player.get_team()] = []
		_teams[player.get_team()].append(player.get_id())
		
		i += 1
		
	for team in _teams.keys():
		Events.team_ready.emit(team, _teams[team])
		# FIXME this could be moved to a team manager
		# FIXME this could use signals for everything, since not all managers or huds are necessarily there
		setup_team(team)
		
	# create the match over screen
	_match_over_screen = match_over_screen_scene.instantiate()
	_match_over_screen.set_players(_active_players)
	_match_over_screen.set_session(session)
	_match_over_screen.hide()
	%HUD.add_child(_match_over_screen)
	
	%PlayersReadyWheels.set_players(_active_players)
	
	
	await Events.battle_start
	# BATTLE START
	
	DeeJay.play(minigame.soundtrack)
	
	for brain in brains_to_enable:
		brain.enabled = true
	
	for player in get_tree().get_nodes_in_group('animation_starts_with_battle'):
		player.play('default')
	
func setup() -> void:
	%TimeManager.set_time(_params.time)
	%Clock.set_value(_params.time)
	%TimeBar.set_max_value(_params.time)
	%TimeBar.set_value(0.0) # time always starts from 0
	%GameOverManager.set_max_score(_params.score)
	%ScoreHUD.set_max_score(_params.score)
	%ScoreHUD.set_starting_score(_params.starting_score)
	
func setup_team(team:String) -> void:
	%ScoreManager.add_team(team)
	var species_list : Array[Species] = []
	for player_id in _teams[team]:
		species_list.append( _players_by_id[player_id].get_species() )
	%ScoreHUD.add_team(team, species_list)
	
## Returns a [String] identifier for the [Arena] (defaults to the file name of the scene file).
func get_id() -> String:
	return scene_file_path.get_file().split('.')[0]
	
## Returns the identifier of the [Minigame] associated with this [Arena], which is the first part of the Arena's identifier (split by underscore).
## For example, if the Arena's identifier is [code]diamondsnatch_2p.tscn[/code], then the Minigame's identifier is [code]diamondsnatch[/code].
func get_minigame_id() -> String:
	return get_id().split('_')[0]
	
## Returns the [Minigame] associated with this [Arena].
## It does this by looking for a resource file named according to [method get_minigame_id] in the [code]res://godot4/data/minigames/[/code] directory.
## For example, if the [Minigame] identifier is [code]diamondsnatch[/code], then the method looks for [code]res://godot4/data/minigames/diamondsnatch.tres[/code].
## If the file is not found, it returns [code]default_minigame[/code] (see [member default_minigame]).
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
	_update_session(data)
	_match_over_screen.update_scores()
	
	# peform a match over animation
	var tween = get_tree().create_tween()
	#tween.set_parallel()
	tween.tween_property(Engine, "time_scale", 0.1, 0.6).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property($Battlefield, "modulate", Color(0.7,0.7,0.7), 0.6).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect( func():
		get_tree().paused = true
		Engine.time_scale = 1
		_match_over_screen.show()
	)

func _update_session(data:Dictionary) -> void:
	session.add_match_results(data)
	
func get_active_players() -> Array[Player]:
	return _active_players
