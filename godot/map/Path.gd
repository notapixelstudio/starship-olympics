extends Line2D

class_name MapPath

const LIMIT_DIST = 201
var from
var to

func _ready():
	var first_point = points[0] + self.position
	for set in get_tree().get_nodes_in_group("sports"):
		var dist = (set.position-first_point).length()
		if dist <=LIMIT_DIST:
			from = set
			break
	
	var last_point = points[len(points)-1] + self.position
	for set in get_tree().get_nodes_in_group("sports"):
		var dist = (set.position-last_point).length()
		if dist <=LIMIT_DIST:
			to = set
			break
		
	print("THIS " + name + " CONNECTS "+ from.planet.id + " AND "+ to.planet.id)
