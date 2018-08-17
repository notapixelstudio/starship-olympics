# script arena

extends Node

var Ship
var AIShip
var width
var height
const MAX_WIN = 3

signal score_current_changed

func _ready():
	Ship = preload('res://actors/Ship.tscn')
	AIShip = preload('res://actors/AIShip.tscn')
	width = get_viewport().size.x
	height = get_viewport().size.y
	global.scores["p1"] = 0
	global.scores["p2"] = 0
	reset()

func update_score(dead_player, killer_player):
	var updated_label
	if dead_player != killer_player:
		global.scores[killer_player] += 1
		if global.scores[killer_player] >= MAX_WIN:
			print("changing scene")
			get_tree().change_scene_to(load('res://screens/gameover_screen/GameOver.tscn'))
		updated_label = get_node('HUD/'+killer_player+'_score')
		updated_label.set_text(str(global.scores[killer_player]))
	else:
		global.scores[dead_player] = max(0, global.scores[dead_player]-1)
		updated_label = get_node('HUD/'+dead_player+'_score')
		updated_label.set_text(str(global.scores[dead_player]))
	
	# after X seconds let's stop all
	var players = get_tree().get_nodes_in_group("players")
	yield(get_tree().create_timer(1.0), "timeout")
	for p in players:
		var wr = weakref(p)
		if wr.get_ref():
			p.alive=false
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
	
	var ship2 = AIShip.instance()
	ship2.player = 'p2'
	ship2.position.x = 32
	ship2.position.y = height/2
	ship2.velocity = Vector2(8,0)
	ship2.color = Color(1,0,0)
	$Battlefield.add_child(ship2)
	ship2.target=ship1
	
func _set_score_current(new_value):
#	count = new_value
	emit_signal("score_current_changed")
	pass