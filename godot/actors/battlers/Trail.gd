# Trail2D
# author: willnationsdev
# brief description: Creates a variable-length trail that tracks the "target" node.
# API details:
# - Use CanvasItem.show_behind_parent or Node2D.z_index (Inspector) to control its layer visibility
# - 'target' and 'target_path' (the 'target vars') will update each other as they are modified
# - If you assign an empty 'target var', the value will automatically update to grab the parent.
#     - To completely turn off the Trail2D, set its `trail_length` to 0
# - The node will automatically update its target vars when it is moved around in the tree
# - You can set the "persistance" mode to have it...
#     - vanish the trail over time (Off)
#     - persist the trail forever, unless modified directly (Always)
#     - persist conditionally:
#         - persist automatically during movement and then shrink over time when you stop
#         - persist according to your own custom logic:
#             - use `bool _should_grow()` to return under what conditions
#               a point should be added underneath the target.
#             - use `bool _should_shrink()` to return under what conditions
#               the degen_rate should be removed from the trail's list of points.

extends Line2D
class_name Trail2D

##### SIGNALS #####

##### CONSTANTS #####

enum Persistance {
	FRAME_RATE_INDIPENDENT,
	OFF,        # Do not persist. Remove all points after the trail_length.
	ALWAYS,     # Always persist. Do not remove any points.
	CONDITIONAL # Sometimes persist. Choose an algorithm for when to add and remove points.

}

enum PersistWhen {
	ON_MOVEMENT, # Add points during movement and remove points when not moving.
	CUSTOM       # Override _should_grow() and _should_shrink() to define when to add/remove points.
}

##### PROPERTIES #####
onready var area_shape = get_node_or_null("NearArea/CollisionShape2D")
onready var area = get_node_or_null("NearArea")
onready var fararea = get_node_or_null("FarArea")
onready var fararea_shape = get_node_or_null("FarArea/CollisionShape2D")

var segments = []
var farsegments = []

# The target node to track
var target: Node2D setget set_target

	
# The NodePath to the target
export var target_path: NodePath = @".." setget set_target_path
# If not persisting, the number of points that should be allowed in the trail
export var trail_length: int = 10
# To what degree the trail should remain in existence before automatically removing points.
export(int, "FrameRateIndependent", "Off", "Always", "Conditional") var persistance: int = Persistance.OFF
# During conditional persistance, which persistance algorithm to use
export(int, "On Movement", "Custom") var persistance_condition: int = PersistWhen.ON_MOVEMENT
# During conditional persistance, how many points to remove per frame
export var degen_rate: int = 1
# If true, automatically set z_index to be one less than the 'target'
export var auto_z_index: bool = true
# If true, will automatically setup a gradient for a gradually transparent trail
export var auto_alpha_gradient: bool = true
export var min_dist : float = 4 
export var time_alive_per_point : float = 1.0

var monitor = []

var actual_length = 0.0
##### NOTIFICATIONS #####

func _init():
	set_as_toplevel(true)
	global_position = Vector2()
	global_rotation = 0
	if auto_alpha_gradient and not gradient:
		gradient = Gradient.new()
		var first = default_color
		first.a = 0
		gradient.set_color(0, first)
		gradient.set_color(1, default_color)

func _notification(p_what: int):
	match p_what:
		NOTIFICATION_PARENTED:
			self.target_path = target_path
			if auto_z_index:
				z_index = target.z_index - 1 if target else 0
		NOTIFICATION_UNPARENTED:
			self.target_path = @""
			self.trail_length = 0


func add_custom_point(point):
	var last_point = Vector2.ZERO if len(points) <= 0 else points[len(points)-1]
	var distanza: float = (last_point-point).length()
	
	if len(points) > 1: 
		if distanza < min_dist:
			return
	if area and not area_shape.disabled:
		add_point_to_segment(point)
	# actual_length += distanza
	add_point(point)
	monitor.append(0.0)


func remove_custom_point(index):
	if area and not area_shape.disabled:
		remove_point_to_segment(index)
	remove_point(index)

		
#warning-ignore:unused_argument
func _process(delta: float):
	if target:
		match persistance:
			Persistance.FRAME_RATE_INDIPENDENT:
				add_custom_point(target.global_position)
				var to_be_deleted_count = 0
				for i in len(monitor):
					monitor[i] += delta
					var time_alive = monitor[i]
					if time_alive > time_alive_per_point:
						to_be_deleted_count += 1
						remove_custom_point(0)
				for d in to_be_deleted_count:
					monitor.remove(0)
			Persistance.OFF:
				add_custom_point(target.global_position)
				while get_point_count() > trail_length :
					remove_custom_point(0)
			Persistance.ALWAYS:
				add_custom_point(target.global_position)
				pass
			Persistance.CONDITIONAL:
				match persistance_condition:
					PersistWhen.ON_MOVEMENT:
						var moved: bool = get_point_position(get_point_count()-1) != target.global_position if get_point_count() else false
						if not get_point_count() or moved:
							add_custom_point(target.global_position)
						else:
							#warning-ignore:unused_variable
							for i in range(degen_rate):
								remove_custom_point(0)
					PersistWhen.CUSTOM:
						if _should_grow():
							add_custom_point(target.global_position)
						if _should_shrink():
							#warning-ignore:unused_variable
							for i in range(degen_rate):
								remove_custom_point(0)

##### OVERRIDES #####

##### VIRTUAL METHODS #####

func _should_grow() -> bool:
	return true

func _should_shrink() -> bool:
	return true

##### PUBLIC METHODS #####

func erase_trail():
	set_process(false)
	monitor = []
	for i in range(get_point_count()):
		remove_custom_point(0)
	yield(get_tree().create_timer(0.01), "timeout")
	set_process(true)

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####

func set_target(p_value: Node2D):
	if p_value:
		if get_path_to(p_value) != target_path:
			target_path = get_path_to(p_value)
	else:
		target_path = @""

func set_target_path(p_value: NodePath):
	target_path = p_value
	target = get_node(p_value) as Node2D if has_node(p_value) else null
	
var entity

const GRACE_POINTS = 15
func add_point_to_segment(point):
	if len(points) == 0:
		return
	segments.append(points[len(points)-1])
	segments.append(point)
	(area_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))

	
	# FarArea
	if len(points) < GRACE_POINTS: 
		return
	farsegments.append(points[len(points)-GRACE_POINTS])
	farsegments.append(points[len(points)-GRACE_POINTS+1])
	(fararea_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))

func remove_point_to_segment(point):
	if len(points) == 0: 
		return
	# Twice, because!
	segments.pop_front()
	segments.pop_front()
	farsegments.pop_front()
	farsegments.pop_front()
	(area_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))
	(fararea_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))
	
