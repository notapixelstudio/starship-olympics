extends Node2D


var ships := []
func _ready():
	ships = [$NewShip, $NewShip2]
	
var i = 0
func _on_timer_timeout():
	var labels = ["normal", "swap"]
	var brains := []
	for s in ships:
		for b in s.get_children():
			if b is Brain:
				brains.append(b)
	for b in brains:
		var index_ship = ships.find(b.get_parent())
		b.reparent(ships[(index_ship+1)%len(ships)], false)
	i+=1
	$Label.text = labels[i%len(labels)]
