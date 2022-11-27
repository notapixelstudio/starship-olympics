tool
extends Area2D
class_name Gate

export var width := 550.0 setget set_width
export var aperture := PI*0.9
#export var crossing_while_still_tolerance := 0.3
export var show_arrow := true setget set_show_arrow

var top_end := Vector2(0, -width/2)
var bottom_end := Vector2(0, width/2)

var overlapping_trackeds := {}
var previous_global_transforms : Array

signal crossed

func set_width(v: float) -> void:
	width = v
	top_end = Vector2(0, -width/2)
	bottom_end = Vector2(0, width/2)
	$RingPart.scale.y = width/550.0
	$BottomRingPart.scale.y = width/550.0
	$Shadow.scale.y = width/550.0
	
func set_show_arrow(v: bool) -> void:
	show_arrow = v
	$Arrow.visible = show_arrow

func _physics_process(delta):
	previous_global_transforms.push_back(global_transform)
	if len(previous_global_transforms) > 2:
		previous_global_transforms.pop_front()
	elif len(previous_global_transforms) < 2: # we need at least one past transform
		return
		
	# mark all trackeds for deletion
	for tracked in overlapping_trackeds.keys():
		overlapping_trackeds[tracked]['good'] = false
		
	for body in get_overlapping_bodies():
		if traits.has_trait(body, 'Tracked'):
			var global_past_position = traits.get_trait(body, 'Tracked').get_previous_global_position()
			if global_past_position == null:
				continue
				
			var relative_position = to_local(body.global_position)
			
			var past = previous_global_transforms[0].xform_inv(global_past_position)
			# save a new past for this tracked if it's new or it has moved enough
			if not overlapping_trackeds.has(body) or relative_position.distance_squared_to(overlapping_trackeds[body]["past"]) > 0.1:
				overlapping_trackeds[body] = {
					"past": past
				}
			overlapping_trackeds[body]['good'] = true
			
			var relative_past_position = overlapping_trackeds[body]["past"] # could be different form the "past" var
			
			var crossing_point = Geometry.segment_intersects_segment_2d(relative_past_position, relative_position, top_end, bottom_end)
			var will_cross : bool = crossing_point is Vector2
			var relative_angle_of_incidence : float = (relative_position - relative_past_position).angle()
			
			if will_cross and abs(relative_angle_of_incidence) > PI/2 + (PI-aperture)/2:
				_crossed_by(body)
				
	# delete trackeds that are still not good
	for tracked in overlapping_trackeds.keys():
		if not overlapping_trackeds[tracked]['good']:
			overlapping_trackeds.erase(tracked)
		
func _crossed_by(sth, trigger=true):
	emit_signal("crossed", sth, self, trigger)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Blink")
	$RandomAudioStreamPlayer.play()
	
func act_as_if_crossed_by(sth):
	_crossed_by(sth, false) # don't trigger
	
#func _draw():
#	if relative_position:
#		draw_circle(relative_position, 6, Color(0, 1, 0))
#	if relative_past_position:
#		draw_circle(relative_past_position, 2, Color(1, 1, 1))
#	if relative_past_position != null and relative_position != null:
#		draw_line(relative_past_position, relative_position, Color(1, 0, 0), 4)
#	draw_line(top_end, bottom_end, Color(1, 0, 1), 2)
