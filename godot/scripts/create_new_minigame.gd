tool
extends EditorScript

const NAME := "Claim The Banner"
const TEMPLATE := "Diamondsnatch"

const LEVELS_BASE_DIR := "res://combat/levels/singles/"
const MINIGAMES_BASE_DIR := "res://combat/minigames/"

func _run():
	var dir = Directory.new()
	
	var camelcase_name = NAME.capitalize().replace(' ','')
	var snakecase_name = NAME.capitalize().to_lower().replace(' ','_')
	
	var template = load(MINIGAMES_BASE_DIR+TEMPLATE+".tres")
	dir.make_dir(LEVELS_BASE_DIR+snakecase_name)
	dir.copy(template.arenas_dir+"/2players.tscn",LEVELS_BASE_DIR+snakecase_name+"/2players.tscn")
	
	var game_mode = GameMode.new()
	game_mode.id = camelcase_name
	game_mode.name = NAME
	
	var minigame = Minigame.new()
	minigame.arenas_dir = LEVELS_BASE_DIR+snakecase_name
	minigame.suit_top = template.suit_top
	minigame.suit_bottom = template.suit_bottom
	ResourceSaver.save("res://combat/minigames/"+camelcase_name+".tres", minigame)
