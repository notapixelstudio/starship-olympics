extends Node2D


var _current_session : Session
var _current_match

var _screen_controller

func _ready() -> void:
	_screen_controller = %ScreenController
	%TouchControls.hide_controls()
	
	Events.pvp_characters_selected.connect(_on_pvp_characters_selected)
	Events.pve_characters_selected.connect(_on_pve_characters_selected)
	Events.level_selection_screen_ready.connect(_on_level_selection_screen_ready)
	Events.level_selected.connect(_on_level_selected)
	
	Events.continue_after_match_over.connect(_on_continue_after_match_over)
	Events.nav_to_level_selection.connect(_on_nav_to_level_selection)
	_screen_controller.transition_ended.connect(_on_screen_transition_ended)

func _on_screen_transition_ended(_action: String, _from_id: String, _to_id: String) -> void:
	%TouchControls.hide_controls()

func _on_ScreenController_transition_started(action:String, from_id:String, to_id:String):
	Events.emit_signal("analytics_event", {"id": UUID.v4(), "action": action, "from": from_id, "to": to_id}, "navigation")
	
func _on_pvp_characters_selected(players:Array[Player]) -> void:
	_current_session = SinglePvpMatchSession.new()
	_current_session.players = players
	
func _on_pve_characters_selected(players:Array[Player]) -> void:
	_current_session = SinglePveMatchSession.new()
	_current_session.players = players
	
func _on_level_selection_screen_ready(level_selection_screen:Screen) -> void:
	level_selection_screen.list_levels_for_session(_current_session)
	
func _on_level_selected(level_scene:PackedScene):
	if _current_match:
		remove_child(_current_match)
		_current_match.queue_free()
		
	await Events.loading_screen_done
	_remove_screens()
	
	_current_match = level_scene.instantiate()
	_current_match.players = _current_session.players
	_current_match.session = _current_session
	add_child(_current_match)
	%TouchControls.show_controls()
	
func _remove_screens():
	remove_child(_screen_controller)
	
func _on_continue_after_match_over():
	reset()
	
func _on_nav_to_level_selection():
	reset()
	
func reset():
	if _current_match:
		remove_child(_current_match)
		_current_match.queue_free()
		
	%TouchControls.hide_controls()
	add_child(_screen_controller)
	_screen_controller.get_current_screen().back.emit()
