extends PinJoint2D

onready var a = get_node(node_a)
onready var b = get_node(node_b)

func _process(delta):
	if not a or not b:
		queue_free()
		return
		
	visible = not(a.about_to_pop or b.about_to_pop)
	$Line2D.gradient.colors = PoolColorArray([a.get_color(), b.get_color()])
	
	var ap = a.global_position
	var bp = b.global_position
	var ar = a.radius*0.74
	var br = b.radius*0.74
	$Line2D.points = PoolVector2Array([ap + ar*(bp-ap).normalized(), bp + br*(ap-bp).normalized()])
	rotation = -get_parent().rotation
	$Line2D.position = -global_position

func _ready():
	$Line2D.gradient = Gradient.new()
	
