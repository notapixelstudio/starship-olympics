tool
extends Area2D

func get_klass():
	return 'Tile'

export var size = 1 setget set_size
export var sides = 4 setget set_sides
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

func set_size(v):
	size = v
	$GRegularPolygon.radius = size*100
	$Graphics/Wrapper.scale = Vector2(size,size)
	$Graphics/Partial.scale = Vector2(size,size)*0.7
	refresh_polygon()
	
func set_sides(v):
	sides = v
	$GRegularPolygon.sides = sides
	refresh_polygon()

func set_owner_ship(v):
	if owner_ship != null:
		emit_signal('lost', owner_ship, self, get_score(), false)
		
	owner_ship = v
	emit_signal('conquered', owner_ship, self, get_score(), false)
	
	$Graphics/Partial.modulate = owner_ship.species.color
	$Graphics/Wrapper/Label.self_modulate = owner_ship.species.color
	
func refresh_polygon():
	var polygon = $GRegularPolygon.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	$Neighbourhood/CollisionPolygon2D.polygon = polygon
	$Graphics/Background.polygon = polygon
	
func _ready():
	refresh_polygon()
	
	$Graphics.position = Vector2(0,32)
	$Graphics/Wrapper/Label.text = '' if points == 1 else str(points)
	yield(get_tree(), "idle_frame") # wait for all tiles to be ready
	
	# tiles don't change neighbours over time
	neighbours = []
	for area in $Neighbourhood.get_overlapping_areas():
		if area != self and area.has_method('get_klass') and area.get_klass() == 'Tile': # trick to avoid circular references
			neighbours.append(area)
			
	$Neighbourhood.queue_free() # delete areas to save physics computations
	
	for n in neighbours:
		max_neighbour_value = max(max_neighbour_value, n.get_score())
	
func _process(delta):
	var bodies = get_overlapping_bodies()
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
		if owner_ship == null or n.owner_ship != owner_ship:
			return
	fortify()
	
func fortify():
	fortified = true
	set_process(false) # disable reconquering
	$Graphics/Background.modulate = owner_ship.species.color
	$Graphics/Background.self_modulate = Color(0.5,0.5,0.5)
	$Graphics/Background.scale = Vector2(1,1)
	$Graphics/Wrapper/Label.modulate = Color(0.3,0.3,0.3)

func get_strategy(ship, distance, game_mode):
	if fortified:
		return {}
		
	if game_mode.name == 'Board Conquest':
		if owner_ship == null and conquering_ship == null:
			return {"seek": max(points, max_neighbour_value*1.1)*0.5} # neighbours are accounted for to enable surrounding big tiles
			
		if owner_ship != ship:
			return {"seek": max(points, max_neighbour_value*1.1)*0.6}
	elif game_mode.name == 'Queen of the Hive':
		if not(ECM.E(ship).has('Royal')):
			return {}
			
		if owner_ship == null and conquering_ship == null:
			return {"seek": points*0.5}
			
		if owner_ship != ship:
			return {"seek": points*0.6}
			
	return {}

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'flip':
		conquering_ship = null
		
func get_score():
	return points
	
