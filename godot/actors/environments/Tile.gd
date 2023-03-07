tool
extends Area2D
class_name Tile

func get_klass():
	return 'Tile'

export var size := 1.0 setget set_size
export var sides = 4 setget set_sides
export var points = 1
export var fortifiable = true
export var need_royal = false
export var foreground_offset := 16
export var background_offset := 32
export var background_scale := 0.85
export var foreground_position := Vector2(0,0)
export var background_color := Color('#212121')
export var fortified_background_scale := Vector2(1.05,1.05)
export var active_area_scale := 1.0
export var neighbour_check_rotation_degrees := 0.0
export var neighbour_check_scale := 1.1

var conquering_ship : Ship
var owner_ship : Ship setget set_owner_ship

var neighbours
var fortified = false
var max_neighbour_value = 0
var on = false

signal conquered
signal lost

func set_size(v: float):
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
	if v == owner_ship: # this could happen when there's a hijacking
		return
		
	if owner_ship != null:
		emit_signal('lost', owner_ship, self, get_score(), false)
		
	owner_ship = v
	emit_signal('conquered', owner_ship, self, get_score(), false)
	
	$Graphics/Partial.modulate = owner_ship.species.color
	#$Graphics/Wrapper/Label.self_modulate = owner_ship.species.color
	
func refresh_polygon():
	var polygon = $GRegularPolygon.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	$Neighbourhood/CollisionPolygon2D.polygon = polygon
	$Foreground.polygon = polygon
	$Graphics/Background.polygon = polygon
	
func _ready():
	refresh_polygon()
	
	$CollisionPolygon2D.scale = active_area_scale*Vector2(1,1)
	$Neighbourhood.rotation_degrees = neighbour_check_rotation_degrees
	$Neighbourhood.scale = neighbour_check_scale*Vector2(1,1)
	$Graphics/Background.scale = background_scale*Vector2(1,1)
	$Foreground.position = foreground_position + Vector2(0,foreground_offset).rotated(-global_rotation)
	$Graphics/Background.self_modulate = background_color
	$Graphics.position = Vector2(0,background_offset).rotated(-global_rotation)
	$Graphics/Wrapper.rotation = -global_rotation
	$Graphics/Wrapper/Label.text = '' if points == 1 else str(points)
	yield(get_tree(), "idle_frame") # wait for all tiles to be ready
	
	# tiles don't change neighbours over time
	neighbours = []
	for area in $Neighbourhood.get_overlapping_areas():
		if area != self and area.has_method('get_klass') and area.get_klass() == 'Tile': # trick to avoid circular references
			neighbours.append(area)
			
	if len(neighbours) > 8:
		print(len(neighbours))
	
	if not Engine.is_editor_hint(): # watch out for deleting this node when this is executed as a tool script!
		$Neighbourhood.queue_free() # delete areas to save physics computations
	
	for n in neighbours:
		max_neighbour_value = max(max_neighbour_value, n.get_score() if n.has_method('get_score') else 0)
	
func _process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Ship and body != owner_ship and conquering_ship == null and not fortified: # no self-conquest + former conqueror takes priority
			if not need_royal or body.get_cargo().check_type('bee_crown'):
				conquering_ship = body
				$AnimationPlayer.play('flip')
		
func conquest():
	set_owner_ship(conquering_ship)
	Events.emit_signal('sth_conquered', conquering_ship, self)
	if fortifiable:
		attempt_fortification()
		for n in neighbours:
			if n.get_player() == get_player() or n.get_conquering_player() == get_player():
				n.attempt_fortification()
	
func attempt_fortification():
	for n in neighbours:
		if not(n.get_player() == get_player() or n.get_conquering_player() == get_player()):
			return
	fortify()
	
func fortify():
	# check if this tile is flipping
	if conquering_ship != null and owner_ship != conquering_ship:
		# hijack flipping
		conquering_ship = owner_ship
		
	fortified = true
	set_process(false) # disable reconquering
	$Foreground.modulate = owner_ship.species.color
	$Foreground.self_modulate = Color(0.7,0.7,0.7)
	$Graphics/Background.modulate = owner_ship.species.color
	$Graphics/Background.self_modulate = Color(0.3,0.3,0.3)
	$Graphics/Background.scale = fortified_background_scale
	$Graphics/Wrapper/Label.modulate = Color(0,0,0)

func get_strategy(ship, distance, game_mode):
	if fortified:
		return {}
		
	if game_mode.name == 'board_conquest':
		if owner_ship == null and conquering_ship == null:
			return {"seek": max(points, max_neighbour_value*1.1)*0.5}
			
		if owner_ship != ship:
			return {"seek": max(points, max_neighbour_value*1.1)*0.6}
	elif game_mode.id == 'queen_of_the_hive':
		if not(ship.get_cargo().check_type('bee_crown')):
			return {}
			
		if owner_ship == null and conquering_ship == null:
			return {"seek": points*0.5}
			
		if owner_ship != ship:
			return {"seek": points*0.6}
			
	return {}
	
func get_strategic_value(ship):
	if fortified:
		return null
		
	if global.the_match.get_game_mode().get_id() == 'board_conquest':
		# neighbours are accounted for to enable surrounding big tiles
		if owner_ship == null and conquering_ship == null:
			return max(points, max_neighbour_value*1.1)*0.5
		if owner_ship != ship:
			return max(points, max_neighbour_value*1.1)*0.6
			
	elif global.the_match.get_game_mode().get_id() == 'queen_of_the_hive':
		if not(ship.get_cargo().check_type('bee_crown')):
			return null
		if owner_ship == null and conquering_ship == null:
			return points*0.5
		if owner_ship != ship:
			return points*0.6
	
	return null
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'flip':
		conquering_ship = null
		
func get_score():
	return points
	
func set_on(player):
	if on or get_player() == null or player != get_player():
		return
	on = true
	modulate = Color(1.7,1.7,1.7)
	propagate()
	
func set_off():
	on = false
	modulate = Color(0.9,0.9,0.9)
	
func propagate():
	if not on or get_player() == null:
		return
		
	for neighbour in neighbours:
		neighbour.set_on(owner_ship.get_player())
		
func get_player():
	if owner_ship == null:
		return null
	return owner_ship.get_player()

func get_conquering_player():
	if conquering_ship == null:
		return null
	return conquering_ship.get_player()

func is_conquered() -> bool:
	return get_player() != null
	
func is_conquerable_by(player) -> bool:
	return get_player() == null or player != get_player()
	
