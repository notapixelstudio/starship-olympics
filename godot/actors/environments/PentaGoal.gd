tool
extends Node2D

export var rings : int = 5 setget set_rings
export var ring_width : float = 50 setget set_ring_width
export var core_radius : float = 100 setget set_core_radius

export var goal_owner : NodePath
var species

var current_ring : int = 0

onready var field = $Field
onready var gshape = $Field/GRegularPolygon

func set_rings(value):
	rings = value
	refresh()

func set_ring_width(value):
	ring_width = value
	refresh()

func set_core_radius(value):
	core_radius = value
	refresh()

func _ready():
	refresh()
	
	# connect feedback signal 
	field.connect("entered", self, "_on_Field_entered")
	
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	for i in range(rings):
		var shape = GRegularPolygon.new()
		shape.sides = 5
		shape.radius = core_radius + ring_width*i
		var ring = Line2D.new()
		ring.default_color = Color(1,1,1,0.7)
		ring.width = 4
		ring.points = shape.to_closed_PoolVector2Array()
		$Rings.add_child(ring)
		
	# set color if goal is owned by a player
	if goal_owner:
		species = get_node(goal_owner).species
		field.modulate = get_node(goal_owner).species.color
		$Rings.modulate = get_node(goal_owner).species.color
		
func refresh():
	if not is_inside_tree():
		return
		
	gshape.radius = core_radius

signal goal_done
func _on_Field_entered(field, body):
	if body is Ship and ECM.E(body).has('Royal') and body.species == species:
		if current_ring < rings-1:
			# increase size
			current_ring += 1
			gshape.call_deferred('set_radius', core_radius + ring_width*current_ring) # without defer, collisions become messed up: one goal triggers other goals
			$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
			emit_signal("goal_done", body)
	elif body is Crown:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		