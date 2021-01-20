extends RigidBody2D

class_name Rock
var RockScene = load('res://actors/environments/Rock.tscn')
var DiamondScene = load('res://combat/collectables/Diamond.tscn')
var BigDiamondScene = load('res://combat/collectables/BigDiamond.tscn')
var StarScene = load('res://combat/collectables/Star.tscn')

export var order : int = 4
export var last_order : int = 2
export var divisions : int = 4
export var base_size : float = 50.0
export var spawn_diamonds : bool = true
export var contains_star : bool = false
export var self_destruct : bool = false
export var self_destruct_position = 'center'
export var lifetime = 6
export var deadly : bool = true
export var ice : bool = false
export var smallest_break : bool = true
export var conquerable : bool = false
export var indestructible = false

var species : Resource
var owner_ship : Ship

var prisoner setget set_prisoner

const colors = {
	'deadly': Color(0.8, 0, 0.85),
	'solid': Color(0.7, 0.7, 0.7),
	'ice': Color(0.2,0.6,0.75)
}

var gshape
var breakable = false setget set_breakable

signal request_spawn

func set_breakable(v):
	breakable = v
	recolor()

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
	$Diamond.visible = spawn_diamonds and order >= last_order
	
	# workaround
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	recolor()
	
	ECM.E(self).get('Deadly').set_enabled(deadly)
	
	$NoRotate/CountdownWrapper.position = Vector2(0,-gshape.height*0.9) if self_destruct_position == 'top' else Vector2(0,0)
	
func _on_Area2D_body_entered(body):
	if body is Bomb:
		try_break()
	elif body is Ship and conquerable:
		conquered_by(body)

func try_break():
	if not breakable:
		return
		
	if prisoner:
		if prisoner is Ship:
			prisoner.rotation_degrees += rotation_degrees-45
		prisoner.linear_velocity = prisoner.linear_velocity.rotated(deg2rad(rotation_degrees-45))
		get_parent().get_parent().call_deferred('add_child', prisoner) # ugly: Battlefield
		yield(prisoner, 'tree_entered')
		# temporary disable collisions to avoid touching the rock
		prisoner.get_node('CollisionShape2D').disabled = true
		if prisoner is Bomb:
			# temporary disable collisions with fields because of freeze rays
			prisoner.set_collision_mask_bit(7, false)
		yield(get_tree().create_timer(0.1), "timeout")
		prisoner.get_node('CollisionShape2D').disabled = false
		if prisoner is Bomb:
			yield(get_tree().create_timer(0.15), "timeout")
			prisoner.set_collision_mask_bit(7, true)
	
	self.breakable = false
	
	if order >= last_order or smallest_break:
		queue_free()
	
	if order < last_order:
		return
	
	var star_index = randi() % divisions
	var indestructible_index = randi() % divisions
	
	for i in range(divisions):
		var child
		if order > last_order+1:
			child = new_child_rock(i)
		elif order == last_order+1:
			if spawn_diamonds and randf() < 0.025:
				child = BigDiamondScene.instance()
				child.appear = false
			else:
				child = new_child_rock(i)
		else: # order <= last_order
			if not spawn_diamonds or randf() < 0.15:
				if contains_star and i == star_index:
					child = StarScene.instance()
				else:
					child = new_child_rock(i)
			else:
				child = DiamondScene.instance()
				child.appear = false
				
		if 'contains_star' in child and contains_star and i == star_index:
			child.contains_star = true
			
		child.position = position + Vector2(gshape.width/2*sqrt(2)*0.4,0).rotated(2*PI/divisions*i)
		child.linear_velocity = 0.5*linear_velocity + Vector2(75*order,0).rotated(2*PI/divisions*i)
		
		if child is Star:
			child.linear_velocity *= 10
		elif child is Diamond:
			pass
		else: # child should be Rock
			if i == indestructible_index and randf() < 0.75:
				child.indestructible = true
				
			if child.indestructible or child.order < last_order:
				child.self_destruct = false
				
			child.start()
		
		emit_signal('request_spawn', child)
		
func new_child_rock(index):
	var child = RockScene.instance()
	child.mass = mass/divisions
	child.order = order - 1
	child.spawn_diamonds = spawn_diamonds
	child.base_size = base_size
	child.last_order = last_order
	child.divisions = divisions
	child.self_destruct = self_destruct
	child.deadly = deadly
	child.ice = ice
	child.smallest_break = smallest_break
	child.species = species
	child.owner_ship = owner_ship
	child.conquerable = conquerable
	child.indestructible = child.order < last_order and not smallest_break
	
	if index == 0:
		child.play_boom()
	
	return child
	
func become_breakable():
	if not indestructible:
		self.breakable = true
	
onready var countdown = $NoRotate/CountdownWrapper/Countdown

func _process(_delta):
	$NoRotate.rotation = -rotation
	
func start():
	if self_destruct:
		if not $SelfDestructTimer.is_inside_tree():
			yield($SelfDestructTimer, 'tree_entered')
			
		$SelfDestructTimer.start(randf())
		
		while lifetime > 0:
			yield($SelfDestructTimer, 'timeout')
			decrease_lifetime()
			$SelfDestructTimer.start(1)
		
func recolor():
	var color = get_color()
	
	$Polygon2D.color = color
	$Line2D.default_color = color
	$LightLine2D.default_color = color
	$LightLine2D2.default_color = color
	$LightLine2D3.default_color = color
	$LightLine2D4.default_color = color
	$LightLine2DE.default_color = color
	$LightLine2DE2.default_color = color
	$LightLine2DE3.default_color = color
	$LightLine2DE4.default_color = color
	
	$NoRotate/CountdownWrapper.scale = Vector2(order, order)
	
	if species:
		$NoRotate/Monogram/Label.text = species.species_name.left(1).to_upper()
		$NoRotate/Monogram.scale = Vector2(order+1, order+1)
		
	if breakable:
		$Polygon2D.self_modulate = Color(1,1,1,0.25)
		$NoRotate.modulate = get_color()
		$Line2D.width = 36
	else:
		$Polygon2D.self_modulate = Color(1,1,1,0.75)
		$NoRotate.modulate = Color(0,0,0,1)
		$Line2D.width = 36
	
func get_color():
	if species:
		return species.color
	elif deadly:
		return colors['deadly']
	elif ice:
		return colors['ice']
	else:
		return colors['solid']
		
func get_score():
	return pow(divisions, order)

signal conquered
signal lost

func conquered_by(ship):
	if ship.species != species:
		if species:
			emit_signal('lost', owner_ship, self, get_score(), false)
		species = ship.species
		owner_ship = ship
		recolor()
		emit_signal('conquered', ship, self, get_score())
		$AnimationPlayer.play("Conquered")

func play_boom():
	$RandomAudioStreamPlayer.play()
	
func get_strategy(ship, distance, game_mode):
	if game_mode.name == 'Asteroid Coloring':
		# claim unclaimed asteroids, according to their score
		if not owner_ship:
			return {"seek": get_score()}
			
		# claim opponents asteroids
		if ship != owner_ship:
			return {"seek": get_score()*1.8}
		
		# protect own asteroids by splitting them, if they can be splitted
		if get_score() > 1 and not indestructible:
			return {"shoot": get_score()*0.25}
			
	# avoid deadly asteroids
	if deadly:
		return {"avoid": 5}
	
	return {"avoid": 0.1}
	
func set_prisoner(v):
	prisoner = v
	if prisoner is Bomb:
		$Prisoner.texture = prisoner.get_node('Sprite').texture
		$Prisoner.rotation_degrees = rad2deg(prisoner.linear_velocity.angle()) - 45
	elif prisoner is Ship:
		$Prisoner.texture = prisoner.species.ship
		$Prisoner.rotation_degrees = prisoner.rotation_degrees - 45
	
func _unhandled_input(event):
	if prisoner and prisoner is Ship:
		if event.is_action_pressed(prisoner.controls+'_fire'):
			$Prisoner/AnimationPlayer.play('Shake')
			decrease_lifetime()
			
func decrease_lifetime():
	lifetime -= 1
	countdown.text = str(lifetime)
	if lifetime == 0:
		try_break()
		
