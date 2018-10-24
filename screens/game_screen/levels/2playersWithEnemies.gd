extends "res://screens/game_screen/Arena.gd"
const MAX_BOIDS = 50
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var boid = preload("res://actors/NPC/EnemyFlock.tscn")

signal created_boid(boid)
func _input(event):
	if event.is_action_pressed("continue"):
		if $Label.text == "steering":
			$Label.text = "fleeing"
		else:
			$Label.text = "steering"
		var bodies = get_tree().get_nodes_in_group( "flock" )
		for b in bodies:
			print(b.steering_mode)
			if b.steering_mode == "steering":
				b.steering_mode = "fleeing"
			else:
				b.steering_mode = "steering"
func _ready():
	for i in range(0, MAX_BOIDS):
		var b = boid.instance()
		b.position = Vector2(700, 300) + Vector2(i* 20, i* 30)
		b.set_target( $Battlefield/p2 )
		get_node("Battlefield").add_child(b)
		connect("created_boid", b, "update_flock")
		emit_signal("created_boid", b)
	

	# Called when the node is added to the scene for the first time.
	# Initialization here