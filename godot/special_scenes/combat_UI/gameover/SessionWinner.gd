extends Control

var winner: InfoPlayer
func _ready():
	var this_session: TheSession = global.get("session")
	if this_session:
		winner = this_session.get_last_winners()[0]
	else:
		winner = InfoPlayer.new()
		winner.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
		
	$"%InsertName".grab_focus()
	$"%WinnerBanner".set_player_from_dictionary(winner.to_dict())

func _on_InsertName_name_inserted(player_real_name: String):
	$"%CanvasLayer".queue_free()
	$"%WinnerBanner".set_player_name(player_real_name)
	$"%Timer".start()


func _on_Timer_timeout():
	Events.emit_signal("nav_to_hall_of_fame", winner.to_dict())
