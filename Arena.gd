extends Node

var Ship
var width
var height

func _ready():
	set_process_input(true)
	Ship = load('res://Ship.tscn')
	width = get_viewport().size.x
	height = get_viewport().size.y
	reset()

func update_score(player):
	var updated_label
	if player == 'p1':
		updated_label = get_node('/root/Arena/HUD/Label2')
	else: 
		updated_label = get_node('/root/Arena/HUD/Label1')
	updated_label.update_score()

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
	ship1.position.x = 32
	ship1.position.y = height/2
	ship1.velocity = Vector2(6,0)
	ship1.color = Color(0,1,0)
	get_node('/root/Arena/Battlefield').add_child(ship1)
	
	var ship2 = Ship.instance()
	ship2.player = 'p2'
	ship2.rotation = PI
	ship2.position.x = width-32
	ship2.position.y = height/2
	ship2.velocity = Vector2(-6,0)
	ship2.color = Color(1,0,0)
	get_node('/root/Arena/Battlefield').add_child(ship2)
	