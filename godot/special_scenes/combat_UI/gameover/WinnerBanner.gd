extends Control

signal champion_has_a_name 

var this_champion : InfoChampion # InfoChampion
export var minigame_logo : PackedScene

func _ready():
	$"%PlayerName".visible = true
	$"%HBoxContainer".visible = false
	$"%LogoMinigame".queue_free()
	
func set_player_name(player_name: String):
	$"%PlayerName".text = player_name

const CARD_POOL_PATH = "res://map/draft/pool"

func set_player(champion: InfoChampion):
	this_champion = champion
	$"%PlayerName".text = champion.player.username if champion.player.username else champion.player.id
	$"%Headshot".set_species(global.get_species(champion.player.species))
	var matches = champion.session_info.get("matches", [])
	var all_cards = null
	if global.the_game != null:
		all_cards = global.the_game.all_cards
	else:
		all_cards = CardPool.new() 
	for a_match in matches:
		var logo = minigame_logo.instance()
		var card_id = a_match["card_id"]
		
		var card: DraftCard = all_cards.get_card(card_id)
		logo.texture = card.get_logo()
		$"%StarsContainer".add_child(logo)
	$"%DateSession".text = cleanup_datetime_str(this_champion.session_info.get("timestamp_local", this_champion.session_info.timestamp_local))
	$"%Background".modulate = global.get_species(champion.player.species).get_color()
	$"%PlayerName".modulate = global.get_species(champion.player.species).get_color()
	$"%InsertName".modulate = global.get_species(champion.player.species).get_color()
	
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
