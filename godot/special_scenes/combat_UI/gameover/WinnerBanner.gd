extends Control

func set_player_name(player_name: String):
	$"%PlayerName".text = player_name


func set_player(champion: InfoChampion):
	$"%PlayerName".text = champion.player.id
	$"%Headshot".set_species(global.get_species(champion.player.species))
	print(champion.to_dict())
	var matches = champion.session_info.get("matches")
	print(matches)
	for a_match in matches:
		var l = Label.new()
		l.text = a_match["card_id"]
		$"%StarsContainer".add_child(l)
