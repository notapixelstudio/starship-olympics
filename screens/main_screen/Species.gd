extends CenterContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (String) var species = "MANTIACS"
export (String) var side = -1
func _ready():
	$VBoxContainer/MarginContainer/TextureRect
	$VBoxContainer/Controls/VBoxContainer/Label.text = species
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
