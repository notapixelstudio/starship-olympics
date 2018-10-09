tool
extends TextureButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal focus_planet(planet)
signal exit_focus_planet(planet)

func _ready():
	$Label.text = name

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_button_navigator_focus_entered():
	if not disabled:
		emit_signal("focus_planet",name)


func _on_button_navigator_focus_exited():
	emit_signal("exit_focus_planet",name)
