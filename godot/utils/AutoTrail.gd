extends Node2D

@export var starting_color := Color(1,1,1,0.1)
@export var ending_color := Color(1,1,1,0)
@export var length := 30
@export var width := 90
@export var max_segment_length := 1000
@export (Trail2D.Persistence) var persistence := Trail2D.Persistence.FRAME_RATE_INDIPENDENT
@export var auto_create_on_enter := true
@export var disappear_speed := 100.0

var trail

# create a new trail each time this node (hence its parent) enters the tree
func _enter_tree():
	if auto_create_on_enter:
		self.create_trail()
	
# drop the trail onto the parent's parent checked exiting the tree
func _exit_tree():
	self.drop_trail()
	
func create_trail():
	trail = Trail2D.new()
	trail.persistence = persistence
	trail.gradient = Gradient.new()
	trail.gradient.set_color(0, ending_color)
	trail.gradient.set_color(1, starting_color)
	trail.trail_length = length
	trail.width = width
	add_child(trail)
	trail.connect('point_added',Callable(self,'_on_trail_point_added'))
	
func drop_trail():
	if not trail or not is_instance_valid(trail) or not is_ancestor_of(trail):
		return
		
	remove_child(trail)
	get_parent().get_parent().call_deferred('add_child', trail)
	trail.call_deferred('disappear', disappear_speed)

func _on_trail_point_added(point: Vector2, last_point):
	if last_point == null:
		return
		
	if point.distance_to(last_point) > max_segment_length:
		trail.remove_last_point()
		self.drop_trail()
		self.create_trail()
