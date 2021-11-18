extends Node

onready var camera = $Camera

var data
var ts_zero := 0
func _ready():
	camera.initialize(compute_arena_size())
	var file_data = global.read_file("user://replay_c64e03a5-4ad0-4cf8-b930-7e3a15aab2ce.json")
	data = file_data["data"]
	ts_zero = data[0]["timestamp"]
	var ts = ts_zero
	for i in range(len(data)):
		var i_elem = data[i]
		var next_timestamp = i_elem["timestamp"]
		
		for k in range(len(i_elem["elements"])):
			var ship = i_elem["elements"][k]
			var pos = str2var(ship["position"])
			var rot = float(ship["rotation"])
			get_node("Ship"+str(k)).setup(pos, rot)
		var wait_time = float(next_timestamp-ts_zero)
		yield(get_tree().create_timer(wait_time/100000.0), "timeout")
		ts = next_timestamp
	


func compute_arena_size():
	"""
	compute the battlefield size
	"""
	return $OutsideWall.get_rect_extents()
