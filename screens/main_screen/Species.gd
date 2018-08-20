extends CenterContainer

export (String) var left = "A"
export (String) var right = "D"
export (String) var fire = "1"
export (String) var species = "ROBOLORDS"
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (int) var side = -1
func _ready():
	# set shortcut for left and right
	print("My name is " + name + " and I have this side " + str(side))
	var mater = $VBoxContainer/MarginContainer/HBoxContainer/TextureRect.get_material() 
	if mater:
		mater.set_shader_param("flip",side < 0)
	$VBoxContainer/Controls/VBoxContainer/Right/Panel/Key.text = right
	$VBoxContainer/Controls/VBoxContainer/Left/Panel/Key.text = left
	$VBoxContainer/Controls/CenterContainer/Fire/Panel/Key.text = fire
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	
	ship.position = Vector2(50,50)
	ship.scale = Vector2(0.5, 0.5)
	change_spieces(species)
	if side < 0:
		ship.get_node("AnimationPlayer").play("standby")
	else:
		ship.flip_h = true
		ship.get_node("AnimationPlayer").play_backwards("standby")
	
	pass

func change_spieces(specie):
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	$VBoxContainer/Controls/VBoxContainer/Label.text = specie.to_upper()
	ship.texture = load("res://actors/"+specie.to_lower()+"_ship.png")
	$VBoxContainer/MarginContainer/HBoxContainer/TextureRect.texture = load("res://assets/character_"+specie.to_lower()+"_1.png")
	print("changed_spieces into from "+species +" to " + specie)
	global.chosen_species[name.to_lower()] = specie
	species = specie
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Previous_pressed():
	change_spieces(global.avalaible_species[1])


func _on_Next_pressed():
	change_spieces(global.avalaible_species[0])
