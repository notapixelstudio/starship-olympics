extends Line2D

class_name MapPath

const LIMIT_DIST = 201

var status : String = "locked" setget set_status # unlocked, locked
var from : MapLocation
var to : MapLocation

func set_status(v):
	status=v
	if not is_inside_tree():
		await self.ready
	visible = (status == "unlocked")
	
func get_id() -> String:
	return self.name
	
func _ready():
	var first_point = points[0] + self.position
	for location in get_tree().get_nodes_in_group("sports"):
		assert(location is MapLocation)
		var dist = (location.position-first_point).length()
		if dist <=LIMIT_DIST:
			from = location
			break
	
	
	var last_point = points[len(points)-1] + self.position
	for location in get_tree().get_nodes_in_group("sports"):
		assert(location is MapLocation)
		var dist = (location.position-last_point).length()
		if dist <=LIMIT_DIST:
			to = location
			break
	
	get_status()

func get_status():
	if TheUnlocker.get_status_path(self.name):
		status = "unlocked"
		visible = true
	else: 
		status = "locked"
		visible = false

func unlock():
	self.status = "unlocked"
	TheUnlocker.unlock_path(self.get_id())
