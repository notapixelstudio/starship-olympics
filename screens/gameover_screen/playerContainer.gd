extends Control

var species 

onready var player = get_node("Player")

var winner = false 
var life_scn = preload("res://screens/game_screen/life_rect.tscn")

func _ready():
	species = global.chosen_species[name.to_lower()]
	species = species.to_lower()
	player.species = species
	var life_texture = load("res://actors/"+species+"_ship_plain.png")
	for i in range(0,global.lives):
		var life = life_scn.instance()
		life.texture = life_texture
		$Lives.add_child(life)
	#rect_scale = Vector2(-1,1)
	$Player.flip(winner)
	
	
func setup(species):
	$Player.setup(species)
	
func remove_lives(points):
	var max_lives = global.lives
	for index in range(0, max_lives - points):
		var life = $Lives.get_child(index)
		life.set_modulate(Color("4b4b4b"))
		
func lose(points):
	$Player.lose()
	remove_lives(points)
	
func win(points):
	winner = true
	$Player.win()
	$Player.selected()
	remove_lives(points)


