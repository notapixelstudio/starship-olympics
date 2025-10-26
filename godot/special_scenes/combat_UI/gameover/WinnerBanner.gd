extends Control

signal champion_has_a_name 

var this_champion : Dictionary # InfoChampion
@export var minigame_logo : PackedScene

func _ready():
	$"%PlayerName".visible = true
	$"%HBoxContainer".visible = false
	$"%LogoMinigame".queue_free()
	
func set_player_name(player_name: String):
	$"%PlayerName".text = player_name

const CARD_POOL_PATH = "res://map/draft/pool"

func set_player(champion: Dictionary):
	this_champion = champion
	return 
	$"%PlayerName".text = champion.player.username if champion.player.username else champion.player.id
	var info_player := Player.new() #InfoPlayer.new()
	# info_player.set_from_dictionary(champion.player)
	$"%Headshot".set_player(info_player)
	
	$"%DateSession".text = cleanup_datetime_str(this_champion.session_info.get("timestamp_local", this_champion.session_info.get("timestamp_local", this_champion.session_info.timestamp)))
	$"%Background".modulate = Settings.get_species(champion.player.species).get_color()
	$"%PlayerName".modulate = Settings.get_species(champion.player.species).get_color()
	$"%InsertName".modulate = Settings.get_species(champion.player.species).get_color()
	$"%InsertName".placeholder_text = $"%PlayerName".text
	
func insert_name():
	$"%InsertName".connect("name_inserted", Callable(self, "_on_InsertName_name_inserted"))
	$"%PlayerName".visible = false
	$"%HBoxContainer".visible = true
	$"%InsertName".grab_focus()
	$"%InsertName".set_process_input(true)


func _on_InsertName_name_inserted(player_name: String):
	set_player_name(player_name)
	$"%PlayerName".visible = true
	$"%HBoxContainer".queue_free()
	$"%PlayerName".text = player_name
	this_champion.get("player", {}).set("username", player_name)
	"""
	if this_game:
		var players = this_game.get_players()
		for player in players:
			if player.id == this_champion.player.id:
				player.username = player_name
	emit_signal("champion_has_a_name")
	"""

func cleanup_datetime_str(datetime_str: String):
	return datetime_str.replace("T", " ")
