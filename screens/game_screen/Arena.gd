# script arena

extends Node

var Ship
var player2
var width
var height


func _ready():
	Ship = preload('res://actors/Ship.tscn')
	if global.enemy == "CPU":
		player2 = preload('res://actors/AIShip.tscn')
	else:
		player2 = Ship
	width = get_viewport().size.x
	height = get_viewport().size.y
	reset()

func update_score(dead_player, killer_player):
	var updated_label
	global.scores[dead_player] -= 1
	print(dead_player + str(global.scores))
	if global.scores[dead_player] <= 0:
			get_tree().change_scene_to(load('res://screens/gameover_screen/GameOver.tscn'))
	# after X seconds let's stop all
	yield(get_tree().create_timer(2.0), "timeout")
	$Popup.update_score()
	$Popup.show()
	get_tree().paused=true

func _on_Explosion_body_entered(body):
	print('boom')

func _input(event):
	if event.is_action_pressed('continue'):
		reset()
		
func reset():
	for child in $Battlefield.get_children():
		child.queue_free()
		remove_child(child)
		
	var ship1 = Ship.instance()
	ship1.player = 'p1'
	ship1.rotation = PI
	ship1.position.x = width-32
	ship1.position.y = height/2
	ship1.velocity = Vector2(-8,0)
	ship1.color = Color(0,1,0)
	$Battlefield.add_child(ship1)
	
	var ship2 = player2.instance()
	ship2.player = 'p2'
	ship2.position.x = 32
	ship2.position.y = height/2
	ship2.velocity = Vector2(8,0)
	ship2.color = Color(1,0,0)
	$Battlefield.add_child(ship2)
	ship2.target=ship1
	ship1.target = ship2