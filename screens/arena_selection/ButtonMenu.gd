extends TextureButton

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var this_mode = get_node("Label")

func _ready():
	this_mode.text = name

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
