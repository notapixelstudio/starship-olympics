extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (String) var species = "TRIXENS"
export (int) var player_num = 1

var life_scn = preload("res://screens/game_screen/life_rect.tscn")

func _ready():
	species = species.to_lower()
	$Player.species = species
	var life_texture = load("res://actors/"+species+"_ship.png")
	for i in range(0,global.lives):
		var life = life_scn.instance()
		life.texture = life_texture
		$Lives.add_child(life)
	rect_scale = Vector2(-1,1)
	$Player.flip(player_num)
	
	
func lose():
	$Player.lose()
	for life in $Lives.get_children():
		life.set_modulate(Color("4b4b4b"))
	
func win():
	$Player.win()
	$Player.selected()


