extends RigidBody2D

class_name Crown
var entity

enum types {CROWN, BALL, SOCCERBALL, TENNISBALL}
export (types) var type = types.CROWN
export var impulse : float = 0
var active : bool = false

var owner_ship = null setget set_owner_ship

const GRAB_DISTANCE = 64

func set_owner_ship(v):
	owner_ship = v
	$RoyalGlow.modulate = owner_ship.species.color if owner_ship else Color(1,1,1,1)

func _ready():
	entity = ECM.E(self)
	
	$CrownSprite.visible = type == types.CROWN
	$BallSprite.visible = type == types.BALL
	$SoccerBallSprite.visible = type == types.SOCCERBALL
	$TennisBallSprite.visible = type == types.TENNISBALL
	
	$CrownShadow.visible = type == types.CROWN
	$BallShadow.visible = type != types.CROWN
	
	if type == types.CROWN:
		$CollisionShape2D.shape.radius = 80
	elif type == types.BALL:
		$CollisionShape2D.shape.radius = 96
	elif type == types.SOCCERBALL:
		$CollisionShape2D.shape.radius = 96
	elif type == types.TENNISBALL:
		$CollisionShape2D.shape.radius = 96
		
	set_physics_process(false)
	
func start():
	set_physics_process(impulse > 0)
	
func _physics_process(_delta):
	apply_central_impulse(impulse*Vector2(1,0).rotated(linear_velocity.angle()))
	
func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity and entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)
	
func get_strategy(ship, distance, game_mode):
	return {"seek": 10}
