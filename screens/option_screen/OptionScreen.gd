extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func _exit_tree():
	for node in $Options.get_children():
		print("this is Option Screen")
		print(node.description, node.value)
		global.set(node.description, node.value)
	# when we leave the scene
	persistance.save_game()
	print(global.lives)


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Options.get_child(0).grab_focus()

func _input(event):
	if event.is_action_pressed("ui_back"):
		get_tree().change_scene(global.from_scene)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Label_focus_entered():
	$Label.modulate = Color(0,1,1)
	print("focuss")
