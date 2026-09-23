extends BackScreen

@export var next_scene : PackedScene

func enter():
	super.enter()
	%SelectionPanel.reset_ready_pilots()
	%SelectionPanel.enable()

func exiting():
	%SelectionPanel.disable()
	super.exiting()
	
func _on_SelectionPanel_selection_completed():
	var players = %SelectionPanel.get_players_data()
	# put all players into the same team
	for player in players:
		player.set_team('GG')
	Events.pve_characters_selected.emit(players)
	
	next.emit(next_scene.instantiate())
	
