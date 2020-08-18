extends Node2D

class_name Pentagonion

export var rings : int = 5 setget set_rings
export var ring_width : float = 50 setget set_ring_width
export var core_radius : float = 100 setget set_core_radius

export var goal_owner : NodePath
var species
var info_player

onready var current_ring : int = rings-1

onready var field = $Field
onready var gshape = $Field/GRegularPolygon

func set_rings(value):
	rings = value

func set_ring_width(value):
	ring_width = value

func set_core_radius(value):
	core_radius = value

func _ready():
	# connect feedback signal 
	field.connect("entered", self, "_on_Field_entered")
	
	for i in range(rings):
		var shape = GRegularPolygon.new()
		shape.sides = 5
		shape.radius = core_radius + ring_width*i
		var ring = Line2D.new()
		ring.default_color = Color(1,1,1,0.7)
		ring.width = 4
		ring.points = shape.to_closed_PoolVector2Array()
		$Rings.add_child(ring)
		
	gshape.radius = core_radius + ring_width*current_ring
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	# set color if goal is owned by a player
	yield(get_tree(), "idle_frame")
	if goal_owner:
		species = get_node(goal_owner).species
		field.modulate = get_node(goal_owner).species.color
		$Rings.modulate = get_node(goal_owner).species.color
		
signal goal_done
func _on_Field_entered(field, body):
	if body is Ship and ECM.E(body).has('Royal') and body.species == species:
		# decrease size
		current_ring -= 1
		$AudioStreamPlayer2D.pitch_scale = 1 + rings-current_ring
		
		if current_ring >= 0:
			gshape.call_deferred('set_radius', core_radius + ring_width*current_ring) # without defer, collisions become messed up: one goal triggers other goals
		
		$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
		emit_signal("goal_done", body)
		
		if current_ring < 0:
			yield(get_tree().create_timer(0.1), "timeout")
			field.queue_free()
			remove_from_group("goal")
			
	elif body is Crown:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		yield($AudioStreamPlayer2D, "finished")
		$AudioStreamPlayer2D.pitch_scale = 1
		
