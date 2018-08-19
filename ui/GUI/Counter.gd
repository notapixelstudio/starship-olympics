extends MarginContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_counter(5)
	pass
	
func set_counter(value):
	$Background/Number.text = str(value)
