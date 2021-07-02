tool

extends RigidBody2D

class_name PowerUp

export (String, 'shield', 'snake', 'sword', 'flail', 'miniballs', 'rockets') var type = 'shield' setget set_type
export var appear = true
export var random_types = []

signal collected

const BEAM_COLORS = {
	# cyan - protective
	'shield': Color(0,1,1,1),
	# magenta - strange
	'snake': Color(1,0,1,1),
	# orange - additions
	'sword': Color(1,0.25,0,1),
	'flail': Color(1,0.25,0,1),
	# red - main weapon
	'miniballs': Color(1,0,0,1),
	'rockets': Color(1,0,0,1)
}

func _ready():
	if not is_inside_tree():
		yield(self, 'ready')
		
	if len(random_types) > 0:
		self.set_type(random_types[randi() % len(random_types)])
	else:
		refresh_type()
	
	if appear:
		$AnimationPlayer.play('AppearFhuFhuFhu')
		yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play('idle')
	activate()
	
func set_type(v):
	type = v
	refresh_type()
	
func refresh_type():
	$Sprite.texture = load('res://assets/sprites/powerups/'+type+'.png')
	$TeleportBeam.modulate = BEAM_COLORS[type]
	
func activate():
	$CollisionShape2D.disabled = false

func get_strategy(ship, distance, game_mode):
	return {"seek": 1}
	
func collect(by):
	queue_free()
	emit_signal('collected', by)
