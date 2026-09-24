extends BackScreen

@export var next_scene : PackedScene

func enter():
	super.enter()
	%SelectionPanel.enable()

func exiting():
	%SelectionPanel.disable()
	super.exiting()

func _on_SelectionPanel_selection_completed():
	var players = %SelectionPanel.get_players_data()
	# put each player into a different team
	for player in players:
		player.set_team(player.get_id())
	Events.pvp_characters_selected.emit(players)
	
	next.emit(next_scene.instantiate())
	
