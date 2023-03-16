tool
extends EditorScript

const NAME := "ClaimTheBanner"
const TEMPLATE := "TakeTheCrown"
const SUIT_TOP := 'red'
const SUIT_BOTTOM := 'red'

const LEVELS_BASE_DIR := "res://combat/levels/singles/"
const MINIGAMES_BASE_DIR := "res://combat/minigames/"

func _run():
	var camelcase_name = NAME.capitalize().replace(' ','')
	var snakecase_name = NAME.capitalize().to_lower().replace(' ','_')
	print(camelcase_name)
	print(snakecase_name)
	
	var template = load(MINIGAMES_BASE_DIR+TEMPLATE+".tres")
	print(template.suit_top)
	
#	var dir = Directory.new()
#	dir.make_dir(LEVELS_BASE_DIR+snakecase_name)
#
#	var minigame = Minigame.new()
#	minigame.arenas_dir = LEVELS_BASE_DIR+snakecase_name
#	minigame.suit_top = SUIT_TOP
#	minigame.suit_bottom = SUIT_BOTTOM
#	ResourceSaver.save("res://combat/minigames/"+camelcase_name+".tres", minigame)
