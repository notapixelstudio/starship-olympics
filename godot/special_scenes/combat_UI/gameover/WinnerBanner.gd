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

func set_banner(champion: Dictionary):
	this_champion = champion
	
	$"%PlayerName".text = champion.get("team", {}).get("username", "GITTIZIO0")
	var players = champion.get("team", {}).get("players", [])
	var i = 0
	# FIXME, please do better
	for headshot in $"%Container".get_children():
		if i > len(players)-1:
			break
		var player = players[i]
		headshot.set_player(player)
		headshot.visible = true
		i+=1
	
	$"%DateSession".text = cleanup_datetime_str(Time.get_datetime_string_from_system(false, true))
	"""
	$"%Background".modulate = Settings.get_species(champion.player.species).get_color()
	$"%PlayerName".modulate = Settings.get_species(champion.player.species).get_color()
	$"%InsertName".modulate = Settings.get_species(champion.player.species).get_color()
	"""
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
