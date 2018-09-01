extends HBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Previous_pressed():
	$Label.text = "Left Arrow has been pressed"


func _on_Next_pressed():
	$Label.text = "Right Arrow has been pressed"


func _on_Select_pressed():
	$Label.text = "SELECT button has been pressed"
