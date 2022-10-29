extends Node2D

class_name Pentagoal


onready var glow_texture = preload('res://assets/sprites/environments/wall_tile.png')

export var rings : int = 5 setget set_rings
export var ring_width : float = 50 setget set_ring_width
export var core_radius : float = 100 setget set_core_radius

export var goal_owner : NodePath
var player

onready var current_ring : int = rings-1

onready var field = $Field
onready var gshape = $Field/GRegularPolygon

func set_rings(value):
	rings = value

func set_ring_width(value):
	ring_width = value

func set_core_radius(value):
	core_radius = value
	
func update_label_size():
	$LabelWrapper.scale = Vector2(1,1)*gshape.radius/100/$LabelWrapper/Label.get_total_character_count()*2

func _ready():
	# connect feedback signal 
	field.connect("entered", self, "_on_Field_entered")
	Events.connect("holdable_dropped", self, "_on_holdable_dropped")
	
	for i in range(rings):
		var shape = GRegularPolygon.new()
		shape.sides = 5
		shape.radius = core_radius + ring_width*i
		var ring = Line2D.new()
		ring.default_color = Color(1,1,1,0.2)
		ring.texture = glow_texture
		ring.texture_mode = Line2D.LINE_TEXTURE_TILE
		ring.width = 32
		ring.points = shape.to_closed_PoolVector2Array()
		$Rings.add_child(ring)
		
	gshape.radius = core_radius + ring_width*current_ring
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		update_label_size()
		
signal goal_done
func _on_Field_entered(field, body):
	if body is Ball:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		yield($AudioStreamPlayer2D, "finished")
		$AudioStreamPlayer2D.pitch_scale = 1
		
func _on_holdable_dropped(holdable, ship, cause):
	if cause != $Field/Area2D: # WARNING this is convoluted
		return
		
	var is_basket_ball = holdable is Ball and holdable.has_type('basket')
	var same_player = ship.get_player() == get_player()
	
	if is_basket_ball and same_player:
		do_goal(ship.get_player(), ship.position)
	
func get_score():
	return 1
	
func do_goal(player, pos):
	if current_ring < 0:
		return
		
	# depleted rings should be moved onto the battlefield surface
	$Rings.get_child(current_ring).position += global.isometric_offset.rotated(-global_rotation)
	
	# decrease size
	current_ring -= 1
	$AudioStreamPlayer2D.pitch_scale = 1 + rings-current_ring
	
	if current_ring >= 0:
		gshape.call_deferred('set_radius', core_radius + ring_width*current_ring) # without defer, collisions become messed up: one goal triggers other goals
		self.call_deferred('update_label_size')
	else:
		$LabelWrapper/Label.queue_free()
		
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	emit_signal("goal_done", player, self, pos)
	
	if current_ring < 0:
		yield(get_tree().create_timer(0.1), "timeout")
		field.queue_free()
		
func set_player(v : InfoPlayer):
	player = v
	field.modulate = player.species.color
	$Rings.modulate = player.species.color
	$LabelWrapper/Label.modulate = player.species.color
	$LabelWrapper/Label.text = player.get_username().to_upper()
	
func get_player():
	return player
