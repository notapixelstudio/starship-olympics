extends Trail
class_name AutoTrail

@export_range (0.0, 100000.0, 1.0, 'suffix:px/s') var disappear_speed := 100.0
@export_range(0, 100000, 1, 'suffix:px') var long_segment_min_length := 1000

var host_parent : Node
var detached := false

func _ready():
	super._ready()
	host_parent = host.get_parent()

func _process(delta):
	if not detached and will_next_segment_be_too_long():
		drop_duplicate()
		
	# reduce the width of the trail if detached, until it reaches zero and then free it
	if detached:
		if width > 0:
			width = max(0, width-delta*disappear_speed)
		else:
			queue_free()
		return
		
	super._process(delta)
	
# drop the trail on exiting the tree
func _exit_tree():
	if not detached:
		drop_duplicate.call_deferred()
		
func will_next_segment_be_too_long() -> bool:
	if curve.get_point_count() < 1:
		return false
	var p1 = curve.get_point_position(curve.get_point_count()-1)
	var p2 = compute_new_point()
	return p1.distance_to(p2) >= long_segment_min_length

## drop this trail onto the host's parent
func drop():
	reparent.call_deferred(host.get_parent())
	detached = true

## drop a duplicate of this trail, then continue with a cleared state
func drop_duplicate():
	var dup = duplicate()
	dup.curve = curve.duplicate()
	dup.timestamps = timestamps.duplicate()
	host_parent.add_child(dup)
	dup.detached = true
	clear()
