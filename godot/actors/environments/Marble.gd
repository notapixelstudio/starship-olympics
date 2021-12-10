tool
extends RigidBody2D

export var radius := 200.0 setget set_radius
export var score := 1

var species : Species
var owner_ship

signal conquered
signal lost

func _ready():
	$Spiral.rotation = randf()*2*PI
	$Decoration/Glow.visible = score > 1
	
func set_radius(v:float) -> void:
	radius = v
	mass = radius/200*25
	$Monogram.scale = radius/200*Vector2(1,1)
	$Decoration.scale = radius/200*Vector2(1.6,1.6)
	$Spiral.scale = radius/200*Vector2(1.6,1.6)
	$CollisionShape2D.shape.radius = radius
	var circle = GCircle.new()
	circle.radius = radius
	circle.precision = 30
	$Polygon2D.set_polygon(circle.to_PoolVector2Array())
	$Shadow.set_polygon(circle.to_PoolVector2Array())
	$Line2D.set_points(circle.to_closed_PoolVector2Array())

func get_score() -> int:
	return score
	
func conquered_by(ship):
	if ship.species != species:
		if species:
			emit_signal('lost', owner_ship, self, get_score(), false)
		species = ship.species
		owner_ship = ship
		recolor()
		emit_signal('conquered', ship, self, get_score())
		
func recolor():
	modulate = species.color
	$Monogram/Label.text = species.get_monogram()
	
func _on_Marble_body_entered(body):
	if body is Ship:
		conquered_by(body)
