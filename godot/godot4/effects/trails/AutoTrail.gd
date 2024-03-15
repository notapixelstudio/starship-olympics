extends Trail
class_name AutoTrail

## A special kind of [Trail] that has the ability to be [method cut]. Whenever an AutoTrail is cut,
## a disappearing copy is dropped onto the host's parent, and the current trail is started anew.
## AutoTrails are also automatically cut when there's a sudden jump (configured via [member
## long_segment_min_length]) or the AutoTrail exits the tree.

## When the trail is cut, the copy that's leaft behind will disappear by shrinking at this rate (px/s).
@export_range (0.0, 100000.0, 1.0, 'suffix:px/s') var disappear_speed := 100.0
## The trail is automatically cut when there's a sudden jump that's longer than this value (px).
@export_range(0, 100000, 1, 'suffix:px') var long_segment_min_length := 1000

var _detached := false

func _process(delta):
	# cut the trail if there's a sudden jump (e.g., portals)
	if not _detached and _will_next_segment_be_too_long():
		cut()
		
	# reduce the width of the trail if detached, until it reaches zero and then free it
	if _detached:
		if width > 0:
			width = max(0, width-delta*disappear_speed)
		else:
			queue_free()
		return
		
	super._process(delta)
	
# cut the trail on exiting the tree (e.g., the host is freed)
func _exit_tree():
	if not _detached:
		cut()
		
# test whether there will be a sudden jump in the trail
func _will_next_segment_be_too_long() -> bool:
	if _curve.get_point_count() < 1:
		return false
	var p1 = _curve.get_point_position(_curve.get_point_count()-1)
	var p2 = compute_new_point()
	return p1.distance_to(p2) >= long_segment_min_length

# drop a duplicate of this trail
func _drop_duplicate():
	var dup = duplicate()
	host.get_parent().add_child.call_deferred(dup)
	dup._detached = true

## Cut this trail, leaving a disappearing copy behind.
func cut() -> void:
	_drop_duplicate()
	clear()
