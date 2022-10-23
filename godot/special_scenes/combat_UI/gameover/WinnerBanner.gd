extends Control

signal champion_has_a_name 

var this_champion : InfoChampion # InfoChampion

func _ready():
	$"%PlayerName".visible = true
	$"%HBoxContainer".visible = false
	this_champion = InfoChampion.new()
	
func set_player_name(player_name: String):
	$"%PlayerName".text = player_name


func set_player(champion: InfoChampion):
	this_champion = champion
	$"%PlayerName".text = champion.player.username if champion.player.username else champion.player.id
	$"%Headshot".set_species(global.get_species(champion.player.species))
	var matches = champion.session_info.get("matches", [])
	for a_match in matches:
		var l = Label.new()
		l.text = a_match["card_id"]
		$"%StarsContainer".add_child(l)
	$"%DateSession".text = cleanup_datetime_str(this_champion.session_info.timestamp)

func insert_name():
	$"%InsertName".connect("name_inserted", self, "_on_InsertName_name_inserted")
	$"%PlayerName".visible = false
	$"%HBoxContainer".visible = true
	$"%InsertName".grab_focus()
	$"%InsertName".set_process_input(true)


func _on_InsertName_name_inserted(player_name: String):
	set_player_name(player_name)
	$"%PlayerName".visible = true
	$"%HBoxContainer".queue_free()
	$"%PlayerName".text = player_name
	this_champion.player.username = player_name
	this_champion.store()
	var this_game : TheGame = global.get("the_game")
	if this_game:
		var players = this_game.get_players()
		for player in players:
			if player.id == this_champion.player.id:
				player.username = player_name
	emit_signal("champion_has_a_name")

func cleanup_datetime_str(datetime_str: String):
	return datetime_str.replace("T", " ")
