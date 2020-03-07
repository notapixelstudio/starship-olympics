extends RigidBody2D

class_name Rock
var RockScene = load('res://actors/environments/Rock.tscn')
var DiamondScene = load('res://combat/collectables/Diamond.tscn')

export var order : int = 4

var gshape
var breakable = false

func _ready():
	gshape = GRegularPolygon.new()
	gshape.sides = 4
	gshape.radius = 50*pow(2,order)
	
	$Polygon2D.polygon = gshape.to_PoolVector2Array()
	$Line2D.points = gshape.to_closed_PoolVector2Array()
	$CollisionShape2D.shape = gshape.to_Shape2D()
	$Area2D/CollisionShape2D.shape = gshape.to_Shape2D()
	
	# workaround
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
func _on_Area2D_body_entered(body):
	if body is Bomb or  body is Ship and not body.invincible:
		try_break()
		
func try_break():
	if not breakable:
		return
	
	queue_free()
	for i in range(4):
		var child
		if order > 1:
			child = RockScene.instance()
			child.mass = mass/4
			child.order = order - 1
		else:
			child = DiamondScene.instance()
		child.position = position + Vector2(gshape.radius*0.4,0).rotated(2*PI/4*i)
		child.linear_velocity = 0.25*linear_velocity + Vector2(50*order,0).rotated(2*PI/4*i)
		get_parent().call_deferred("add_child", child)
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Forming':
		breakable = true
		