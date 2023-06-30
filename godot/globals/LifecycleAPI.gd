extends Node


func _init():
	# events connected and logged
	Events.connect('execution_started', self, '_on_execution_started')
	Events.connect('game_started', self, '_on_game_started')
	Events.connect('session_started', self, '_on_session_started')
	Events.connect('match_started', self, '_on_match_started')
	Events.connect('match_ended', self, '_on_match_ended')
	Events.connect('session_ended', self, '_on_session_ended')
	Events.connect('game_ended', self, '_on_game_ended')
	Events.connect('execution_ended', self, '_on_execution_ended')
	Events.connect('draft_ended', self, '_on_draft_ended')
	Events.connect('analytics_enabled', self, '_on_analytics_enabled')
	Events.connect('analytics_disabled', self, '_on_analytics_disabled')


func _on_draft_ended(choices:Dictionary, hand:Array) -> void:
	pass
	
func _on_minigame_selected(picked_card: DraftCard) -> void:
	pass

func _on_analytics_enabled() -> void:
	var event_name = "analytics_enabled"
	var data = {"id": UUID.v4()}
	Events.emit_signal("analytics_event", data, event_name)
	
func _on_analytics_disabled() -> void:
	var event_name = "analytics_disabled"
	var data = {"id": UUID.v4()}
	Events.emit_signal("analytics_event", data, event_name)

var execution_started_ms : int
func _on_execution_started() -> void:
	execution_started_ms = OS.get_ticks_msec()
	var event_name = "execution_started"
	var data = {"id": global.execution_uuid}
	Events.emit_signal("analytics_event", data, event_name)
	
	
func _on_execution_ended() -> void:
	var event_name = "execution_ended"
	var data = {"id": global.execution_uuid}
	Events.emit_signal("analytics_event", data, event_name)
	
	
var game_started_ms : int
func _on_game_started() -> void:
	game_started_ms = OS.get_ticks_msec()
	var event_name = "game_started"
	var data = {"id": global.the_game.get_uuid(), "human_players": len(global.the_game.get_human_players())}
	Events.emit_signal("analytics_event", data, event_name)
	
	
func _on_game_ended() -> void:
	var event_name = "game_ended"
	var data = {"id":global.the_game.get_uuid(),"duration_ms":OS.get_ticks_msec() - game_started_ms}
	Events.emit_signal("analytics_event", data, event_name)
	
	
var session_started_ms : int
func _on_session_started() -> void:
	session_started_ms = OS.get_ticks_msec()
	var event_name = "session_started"
	var data = {"id":global.session.get_uuid()}
	Events.emit_signal("analytics_event", data, event_name)
	
	
func _on_session_ended() -> void:
	var event_name = "session_ended"
	var data = {"id":global.session.get_uuid(),"duration_ms":OS.get_ticks_msec() - session_started_ms}
	Events.emit_signal("analytics_event", data, event_name)
	
	
var match_started_ms : int
func _on_match_started() -> void:
	match_started_ms = OS.get_ticks_msec()
	var event_name = "match_started"
	var data = {"id": global.the_match.get_uuid(), "minigame_id":global.the_match.get_minigame_id(), "card_id":  global.the_match.get_card_id()}
	Events.emit_signal("analytics_event", data, event_name)

func _on_match_ended(match_dict: Dictionary) -> void:
	var event_name = "match_ended"
	var data = {"id":global.the_match.get_uuid(),"duration_ms":OS.get_ticks_msec() - game_started_ms, "minigame_id": global.the_match.get_minigame_id(), "card_id":  global.the_match.get_card_id()}
	Events.emit_signal("analytics_event", data, event_name)
