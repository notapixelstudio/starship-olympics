extends Screen

@export var next_scene : PackedScene

func enter():
	super.enter()
	%SelectionPanel.reset_ready_pilots()
	%SelectionPanel.enable()

func exiting():
	%SelectionPanel.disable()
	super.exiting()
	
func _on_selection_panel_selection_completed() -> void:
	var players = %SelectionPanel.get_players_data()
	# put all players into the same team
	for player in players:
		player.set_team('GG')
	Events.pve_characters_selected.emit(players)
	
	next.emit(next_scene.instantiate())
	
func _on_selection_panel_back_requested() -> void:
	back.emit()
