extends BackScreen

@export var next_scene : PackedScene
var _selection_completed := false

func enter():
	super.enter()
	_selection_completed = false
	%SelectionPanel.enable()

func exiting():
	%SelectionPanel.disable()
	super.exiting()
	
func _on_SelectionPanel_selection_completed():
	_selection_completed = true
	next.emit(next_scene.instantiate())
	
func exited():
	super.exited()
	if _selection_completed:
		var players = %SelectionPanel.get_players_data()
		# put all players into the same team
		for player in players:
			player.set_team('GG')
		Events.campaign_game_start.emit(players)
