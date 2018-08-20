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
	print("My name is " + name + " and I have this side " + str(side))
	var mater = $VBoxContainer/MarginContainer/TextureRect.get_material() 
	if mater:
		mater.set_shader_param("flip",side < 0)
	$VBoxContainer/Controls/VBoxContainer/Label.text = species.to_upper()
	$VBoxContainer/Controls/VBoxContainer/Right/Panel/Key.text = right
	$VBoxContainer/Controls/VBoxContainer/Left/Panel/Key.text = left
	$VBoxContainer/Controls/CenterContainer/Fire/Panel/Key.text = fire
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	
	ship.position = Vector2(50,50)
	ship.scale = Vector2(0.5, 0.5)
	ship.texture = load("res://actors/"+species.to_lower()+"_ship.png")
	if side < 0:
		ship.get_node("AnimationPlayer").play("standby")
	else:
		ship.flip_h = true
		ship.get_node("AnimationPlayer").play_backwards("standby")
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
