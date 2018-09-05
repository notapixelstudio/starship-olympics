extends "res://screens/basic_screen.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (String) var new_species = "trixens"

func _ready():
	$Ship.visible = false
	$Character.visible = false
	global.unlocked_species.append(new_species)
	global.unlocked += 1
	yield(get_tree().create_timer(2.0), "timeout")
	$Ship.texture = load("res://actors/"+new_species+"_ship.png")
	$Character.texture = load("res://assets/character_"+new_species+"_1.png")
	var sprite = get_node("Ship")
	var tween = get_node("Tween")
	sprite.visible = true
	$Character.visible = true
	var size = get_viewport().size
	tween.interpolate_method(sprite, "set_position", Vector2(0, 0), get_viewport().size/2, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#tween.interpolate_property(sprite, "position", get_viewport().size/2, Vector2(0, 0), 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 2)
	tween.interpolate_method($Character, "set_position", Vector2(0, size.y), Vector2(size.x/2+200, size.y/2), 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	$Button.visible = true
	$Button.disabled = false
	$Button.grab_focus()
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed():
	persistance.save_game()
	change_scene()
