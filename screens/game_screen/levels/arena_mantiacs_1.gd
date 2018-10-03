extends "res://screens/game_screen/Arena.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
var wanderer = preload("res://actors/NPC/EnemyWanderer.tscn")

func _process(delta):
	if Input.is_action_just_pressed("continue"):
		var w = wanderer.instance()
		w.position = Vector2(randi() % int(OS.window_size.x), randi() % int(OS.window_size.y))
		$World/Battlefield.add_child(w)
		
		
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
