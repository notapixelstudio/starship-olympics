extends Node2D

var brains:= []
var ships := []
func _ready():
	brains = [$NewShip/PlayerBrain, $NewShip2/PlayerBrain]
	ships = [$NewShip, $NewShip2]
func _process(delta):
	$Label2.text = str(Input.get_action_strength("ui_right"))
	
var i = 0
func _on_timer_timeout():
	var labels = ["normal", "swap"]
	for b in get_tree().get_nodes_in_group('brains'):
		var index_ship = ships.find(b.get_parent())
		b.reparent(ships[(index_ship+1)%len(ships)], false)
	i+=1
	$Label.text = labels[i%len(labels)]
