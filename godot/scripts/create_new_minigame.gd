tool
extends EditorScript

const NAME := "Spikeball"
const also_winter := true

const TEMPLATE := "Snipermatch"

const LEVELS_BASE_DIR := "res://combat/levels/singles/"
const GAME_MODES_BASE_DIR := "res://combat/modes/"
const STYLES_BASE_DIR := "res://combat/styles/"
const MINIGAMES_BASE_DIR := "res://combat/minigames/"
const CARDS_BASE_DIR := "res://map/draft/cards/"

func _run():
	# load the template minigame
	var template = load(MINIGAMES_BASE_DIR+TEMPLATE+".tres")
	
	# create a new game mode
	create_game_mode_resource(template)

	# create a new minigame using the game mode
	create_minigame_resource(template)

	# create new cards for the minigame
	create_card_resource()
	if also_winter:
		create_card_resource(true)
		
	# create the levels directory and a 2 players Arena
	create_base_level(template)
	
func create_base_level(template):
	# create the directory for new levels
	var dir = Directory.new()
	dir.make_dir(LEVELS_BASE_DIR+snakecase(NAME))
	
	# instance the template Arena
	var template_instance = load(template.arenas_dir+"/2players.tscn").instance(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
	
	# modify it by pointing to the new game mode
	template_instance.game_mode = load(GAME_MODES_BASE_DIR+camelcase(NAME)+".tres")
	
	# save it as a new file
	var packed_scene = PackedScene.new()
	packed_scene.pack(template_instance)
	var new_level_path = LEVELS_BASE_DIR+snakecase(NAME)+"/2players.tscn"
	packed_scene.take_over_path(new_level_path)
	ResourceSaver.save(new_level_path, packed_scene, ResourceSaver.FLAG_CHANGE_PATH)
	
func create_game_mode_resource(template):
	# duplicate the game mode from the template
	var game_mode = template.game_mode.duplicate()
	game_mode.id = camelcase(NAME)
	game_mode.name = NAME
	
	# also, duplicate a new style from the template's game mode (and save it)
	var style = game_mode.arena_style.duplicate()
	game_mode.arena_style = style
	var style_path = STYLES_BASE_DIR+snakecase(NAME)+".tres"
	style.take_over_path(style_path)
	ResourceSaver.save(style_path, style, ResourceSaver.FLAG_CHANGE_PATH)
	
	# save the game mode as a new Resource
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
	
