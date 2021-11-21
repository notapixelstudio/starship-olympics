extends Node

onready var camera = $Camera
onready var anim = $AnimationPlayer

var data
var ts_zero := 0

	
func _ready():
	camera.initialize(compute_arena_size())
	
	var animation = anim.get_animation("replay")
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Enemy:position:x")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 0.5, 100)


	var file_data = global.read_file("user://replay_883f7d01-5af4-4b9a-9439-79d5f538ec4c.json")
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
