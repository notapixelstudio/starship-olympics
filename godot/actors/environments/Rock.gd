extends RigidBody2D

class_name Rock
var RockScene = load('res://actors/environments/Rock.tscn')
var DiamondScene = load('res://combat/collectables/Diamond.tscn')
var BigDiamondScene = load('res://combat/collectables/BigDiamond.tscn')
var StarScene = load('res://combat/collectables/Star.tscn')

export var order : int = 4
export var last_order : int = 1
export var divisions : int = 4
export var base_size : float = 50.0
export var spawn_diamonds : bool = true
export var contains_star : bool = false

var gshape
var breakable = false

signal request_spawn

func _ready():
	if contains_star:
		spawn_diamonds = false
	
	gshape = GBeveledRect.new()
	gshape.width = 2*base_size/sqrt(2)*pow(2,order)
	gshape.height = gshape.width
	gshape.bevel_ne = gshape.width*0.2 * (1 + randf()*0.5)
	gshape.bevel_se = gshape.width*0.2 * (1 + randf()*0.5)
	gshape.bevel_nw = gshape.width*0.2 * (1 + randf()*0.5)
	gshape.bevel_sw = gshape.width*0.2 * (1 + randf()*0.5)
	gshape.jitter = base_size/5.0*pow(2,order)
	$Polygon2D.polygon = gshape.to_PoolVector2Array()
	$Line2D.points = gshape.to_closed_PoolVector2Array()
	var epoints = gshape.to_PoolVector2Array()
	var ipoints = gshape.to_PoolVector2Array_offset(Vector2(0,0), 0.7)
	$LightLine2D.points = PoolVector2Array([ipoints[0],ipoints[2]])
	$LightLine2D2.points = PoolVector2Array([ipoints[2],ipoints[4]])
	$LightLine2D3.points = PoolVector2Array([ipoints[4],ipoints[6]])
	$LightLine2D4.points = PoolVector2Array([ipoints[6],ipoints[0]])
	$LightLine2DE.points = PoolVector2Array([epoints[0], ipoints[0],epoints[1]])
	$LightLine2DE2.points = PoolVector2Array([epoints[2], ipoints[2],epoints[3]])
	$LightLine2DE3.points = PoolVector2Array([epoints[4], ipoints[4],epoints[5]])
	$LightLine2DE4.points = PoolVector2Array([epoints[6], ipoints[6],epoints[7]])
	$CollisionShape2D.shape = gshape.to_Shape2D()
	$Area2D/CollisionShape2D.shape = gshape.to_Shape2D()
	rotation_degrees = 45
	
	$Star.visible = contains_star
	
	# workaround
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
func _on_Area2D_body_entered(body):
	if body is Bomb:
		try_break()

func try_break():
	if not breakable:
		return
	
	breakable = false
	queue_free()
	
	if order < last_order:
		return
	
	var star_index = randi() % divisions
	
	for i in range(divisions):
		var child
		if order > last_order+1:
			child = new_child_rock()
		elif order == last_order+1:
			if spawn_diamonds and randf() < 0.025:
				child = BigDiamondScene.instance()
			else:
				child = new_child_rock()
		else: # order <= last_order
			if not spawn_diamonds or randf() < 0.25:
				if contains_star and i == star_index:
					child = StarScene.instance()
				else:
					child = new_child_rock()
			else:
				child = DiamondScene.instance()
				
		if 'contains_star' in child and contains_star and i == star_index:
			child.contains_star = true
			
		child.position = position + Vector2(gshape.width/2*sqrt(2)*0.4,0).rotated(2*PI/divisions*i)
		child.linear_velocity = 0.5*linear_velocity + Vector2(50*order,0).rotated(2*PI/divisions*i)
		emit_signal('request_spawn', child)
		
func new_child_rock():
	var child = RockScene.instance()
	child.mass = mass/divisions
	child.order = order - 1
	child.spawn_diamonds = spawn_diamonds
	child.base_size = base_size
	child.last_order = last_order
	child.divisions = divisions
	
	return child
	
func become_breakable():
	breakable = true
	
func _process(delta):
	$Star.rotation = -rotation
	
