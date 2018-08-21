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
	# https://github.com/godotengine/godot/issues/15979
	var hotkey = InputEventKey.new() # weird, but no `.new`
	if left != "A":
		hotkey.scancode = KEY_LEFT
	else:
		hotkey.scancode = KEY_A
	var shortcut = ShortCut.new()
	shortcut.set_shortcut(hotkey)
	# and then on BaseButton
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.set_shortcut(shortcut)
	
	hotkey = InputEventKey.new() # weird, but no `.new`
	if right != "D":
		hotkey.scancode = KEY_RIGHT
	else:
		hotkey.scancode = KEY_D
	shortcut = ShortCut.new()
	shortcut.set_shortcut(hotkey)
	# and then on BaseButton
	$VBoxContainer/MarginContainer/HBoxContainer/Next.set_shortcut(shortcut)
	print("My name is " + name + " and I have this side " + str(side))
	$VBoxContainer/Controls/VBoxContainer/Right/Panel/Key.text = right
	$VBoxContainer/Controls/VBoxContainer/Left/Panel/Key.text = left
	$VBoxContainer/Controls/CenterContainer/Fire/Panel/Key.text = fire
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	var characterSprite = $VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite
	
	ship.position = Vector2(50,50)
	ship.scale = Vector2(0.5, 0.5)
	characterSprite.position = Vector2(65,200)
	characterSprite.scale = Vector2(0.43, 0.43)
	change_spieces(species)
	if side != 0:
		ship.get_node("AnimationPlayer").play("standby")
	else:
		ship.get_node("AnimationPlayer").play_backwards("standby")
	ship.flip_h = not side
	characterSprite.flip_h = side
	pass

func change_spieces(specie):
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	$VBoxContainer/Controls/VBoxContainer/Label.text = specie.to_upper()
	ship.texture = load("res://actors/"+specie.to_lower()+"_ship.png")
	$VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.texture = load("res://assets/character_"+specie.to_lower()+"_1.png")
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
