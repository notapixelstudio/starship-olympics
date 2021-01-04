extends Node2D

export var size = 1
export var points = 1
export var fortifiable = true
export var need_royal = false

var conquering_ship : Ship
var owner_ship : Ship setget set_owner_ship

var neighbours
var fortified = false
var max_neighbour_value = 0

signal conquered
signal lost

func set_owner_ship(v):
	if owner_ship != null:
		emit_signal('lost', owner_ship, self, get_score(), false)
		
	owner_ship = v
	emit_signal('conquered', owner_ship, self, get_score(), false)
	
	$Graphics/Partial.modulate = owner_ship.species.color
	$Graphics/Fortification.modulate = owner_ship.species.color
	$Graphics/Wrapper/Label.self_modulate = owner_ship.species.color
	
func _ready():
	scale = Vector2(size, size)
	$Graphics.position = Vector2(0,32/size)
	$Graphics/Wrapper/Label.text = '' if points == 1 else str(points)
	yield(get_tree(), "idle_frame") # wait for all tiles to be ready
	neighbours = get_parent().get_neighbours(self) # tiles don't change neighbours over time
	
	for n in neighbours:
		max_neighbour_value = max(max_neighbour_value, n.get_score())
	
func _process(delta):
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Ship and body != owner_ship and conquering_ship == null: # no self-conquest + former conqueror takes priority
			if not need_royal or ECM.E(body).has('Royal'):
				conquering_ship = body
				$AnimationPlayer.play('flip')
		
func conquest():
	set_owner_ship(conquering_ship)
	if fortifiable:
		attempt_fortification()
		for n in neighbours:
			n.attempt_fortification()
	
func attempt_fortification():
	for n in neighbours:
		if n.owner_ship != owner_ship:
			return
	fortify()
	
func fortify():
	fortified = true
	set_process(false) # disable reconquering
	$Graphics/Fortification.visible = true
	$Graphics/Wrapper/Label.modulate = Color(0.3,0.3,0.3)

func get_strategy(ship, distance, game_mode):
	if fortified:
		return {}
		
	if owner_ship == null and conquering_ship == null:
		return {"seek": max(points, max_neighbour_value*1.1)*0.5} # neighbours are accounted for to enable surrounding big tiles
		
	if owner_ship != ship:
		return {"seek": max(points, max_neighbour_value*1.1)*0.6}
		
	return {}

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'flip':
		conquering_ship = null
		
func get_score():
	return points
	
