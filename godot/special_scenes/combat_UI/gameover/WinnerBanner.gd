extends Control

func set_player_name(player_name: String):
	$"%PlayerName".text = player_name


func set_player_from_dictionary(player_info: Dictionary):
	$"%PlayerName".text = player_info.id
	$"%Headshot".set_species(global.get_species(player_info.species))
	
