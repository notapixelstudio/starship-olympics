extends Node2D

@export var game_scene_2p : PackedScene
@export var game_scene_3p: PackedScene
@export var game_scene_4p: PackedScene
@export var game_scene_1pve: PackedScene
@export var game_scene_2pve: PackedScene
@export var game_scene_3pve: PackedScene
@export var game_scene_4pve: PackedScene

var _screen_controller
var _current_game

func _ready() -> void:
	_screen_controller = %ScreenController
	
	Events.versus_game_start.connect(begin_versus_game)
	Events.campaign_game_start.connect(begin_campaign_game)
	Events.continue_after_match_over.connect(reset)

func _on_ScreenController_transition_started(action:String, from_id:String, to_id:String):
	Events.emit_signal("analytics_event", {"id": UUID.v4(), "action": action, "from": from_id, "to": to_id}, "navigation")
	
func begin_versus_game(players:Array[Player]) -> void:
	var session = SingleMatchSession.new()
	var player_count = len(players)
	
	if player_count == 2:
		new_game(session, players, game_scene_2p)
	elif player_count == 3:
		new_game(session, players, game_scene_3p)
	elif player_count == 4:
		new_game(session, players, game_scene_4p)
		
func begin_campaign_game(players:Array[Player]) -> void:
	var session = SinglePveMatchSession.new()
	var player_count = len(players)
	
	if player_count == 1:
		new_game(session, players, game_scene_1pve)
	elif player_count == 2:
		new_game(session, players, game_scene_2pve)
	elif player_count == 3:
		new_game(session, players, game_scene_3pve)
	elif player_count == 4:
		new_game(session, players, game_scene_4pve)
	
func new_game(session:Session, players:Array[Player], game_scene:PackedScene):
	if _current_game:
		remove_child(_current_game)
		_current_game.queue_free()
		
	await Events.loading_screen_done
	_remove_screens()
	
	_current_game = game_scene.instantiate()
	_current_game.players = players
	_current_game.session = session
	add_child(_current_game)
	
func _remove_screens():
	remove_child(_screen_controller)
	
func reset():
	if _current_game:
		remove_child(_current_game)
		_current_game.queue_free()
		
	add_child(_screen_controller)
	_screen_controller.get_current_screen().back.emit()
