tool
extends EditorScript

const NAME := "Claim the Banner"
const also_winter := true

const TEMPLATE := "TakeTheCrown"

const LEVELS_BASE_DIR := "res://combat/levels/singles/"
const GAME_MODES_BASE_DIR := "res://combat/modes/"
const MINIGAMES_BASE_DIR := "res://combat/minigames/"
const CARDS_BASE_DIR := "res://map/draft/cards/"

func _run():
	# load the template minigame
	var template = load(MINIGAMES_BASE_DIR+TEMPLATE+".tres")
	
#	# create a new game mode
#	create_game_mode_resource()
#
#	# create a new minigame using the game mode
#	create_minigame_resource(template)
#
#	# create new cards for the minigame
#	create_card_resource()
#	if also_winter:
#		create_card_resource(true)
		
	# create the levels directory and copy a 2 players Arena in it from the template
	var base_level_path = LEVELS_BASE_DIR+snakecase(NAME)+"/2players.tscn"
	create_base_level(template, base_level_path)
	var base_level = load(base_level_path)
	print(base_level)
	
func create_base_level(template, base_level_path):
	var dir = Directory.new()
	dir.make_dir(LEVELS_BASE_DIR+snakecase(NAME))
	dir.copy(template.arenas_dir+"/2players.tscn", base_level_path)
	
func create_game_mode_resource():
	var game_mode = GameMode.new()
	game_mode.id = camelcase(NAME)
	game_mode.name = NAME
	var game_mode_path = GAME_MODES_BASE_DIR+camelcase(NAME)+".tres"
	game_mode.take_over_path(game_mode_path)
	ResourceSaver.save(game_mode_path, game_mode, ResourceSaver.FLAG_CHANGE_PATH)
	
func create_minigame_resource(template):
	var minigame = Minigame.new()
	minigame.game_mode = load(GAME_MODES_BASE_DIR+camelcase(NAME)+".tres")
	minigame.arenas_dir = LEVELS_BASE_DIR+snakecase(NAME)
	minigame.suit_top = template.suit_top
	minigame.suit_bottom = template.suit_bottom
	var minigame_path = MINIGAMES_BASE_DIR+camelcase(NAME)+".tres"
	minigame.take_over_path(minigame_path)
	ResourceSaver.save(minigame_path, minigame, ResourceSaver.FLAG_CHANGE_PATH)
	
func create_card_resource(winter=false):
	var card = DraftCard.new()
	card.minigame = load(MINIGAMES_BASE_DIR+camelcase(NAME)+".tres")
	card.winter = winter
	var card_path = CARDS_BASE_DIR+('Winter' if winter else '')+camelcase(NAME)+".tres"
	card.take_over_path(card_path)
	ResourceSaver.save(card_path, card, ResourceSaver.FLAG_CHANGE_PATH)

func camelcase(s: String) -> String:
	return s.capitalize().replace(' ','')
	
func snakecase(s: String) -> String:
	return s.capitalize().to_lower().replace(' ','_')
	
