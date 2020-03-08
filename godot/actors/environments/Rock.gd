extends RigidBody2D

class_name Rock
var RockScene = load('res://actors/environments/Rock.tscn')
var DiamondScene = load('res://combat/collectables/Diamond.tscn')
var BigDiamondScene = load('res://combat/collectables/BigDiamond.tscn')

export var order : int = 4

var gshape

func _ready():
	gshape = GRegularPolygon.new()
	gshape.sides = 4
	gshape.radius = 45*pow(2,order)
	
	$Polygon2D.polygon = gshape.to_PoolVector2Array()
	$Line2D.points = gshape.to_closed_PoolVector2Array()
	$CollisionShape2D.shape = gshape.to_Shape2D()
	$Area2D/CollisionShape2D.shape = gshape.to_Shape2D()
	
	# workaround
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
func _on_Area2D_body_entered(body):
	if body is Bomb or body is Ship and not body.invincible:
		queue_free()
		
		if order < 1:
			return
		
		for i in range(4):
			var child
			if order > 1:
				child = new_child_rock()
			else:
				var chance = randf()
				if chance < 0.025:
					child = BigDiamondScene.instance()
				elif chance < 0.33:
					child = new_child_rock()
				else:
					child = DiamondScene.instance()
			child.position = position + Vector2(gshape.radius*0.4,0).rotated(2*PI/4*i)
			child.linear_velocity = 0.25*linear_velocity + Vector2(50*order,0).rotated(2*PI/4*i)
			get_parent().call_deferred("add_child", child)
			
func new_child_rock():
	var child = RockScene.instance()
	child.mass = mass/4
	child.order = order - 1
	return child
	