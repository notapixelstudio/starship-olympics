extends Node2D


var ships := []
func _ready():
	ships = [$Ship, $Ship2]
	
var i = 0
func _on_timer_timeout():
	ships[0].global_position = Vector2(0, 0)
	
#	var labels = ["normal", "swap"]
#	var brains := []
#	for s in ships:
#		for b in s.get_children():
#			if b is Brain:
#				brains.append(b)
#	for b in brains:
#		var index_ship = ships.find(b.get_parent())
#		b.reparent(ships[(index_ship+1)%len(ships)], false)
#	i+=1
#	$Label.text = labels[i%len(labels)]
