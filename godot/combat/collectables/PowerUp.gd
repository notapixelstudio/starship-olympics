tool

extends RigidBody2D

class_name PowerUp

export (String, 'shield', 'magnet', 'snake', 'kamikaze', 'sword', 'scythe', 'flail', 'miniballs', 'rockets', 'spikes', 'bombs', 'waves', 'bubbles') var type = 'shield' setget set_type
export var appear = true
export var tease = false
export var random_types = []

signal collected

const CATEGORY = {
	'shield': 'protection',
	'magnet': 'protection',
	
	'snake': 'strange',
	'kamikaze': 'strange',
	
	'sword': 'addition',
	'scythe': 'addition',
	'flail': 'addition',
	
	'rockets': 'main',
	'miniballs': 'main',
	'spikes': 'main',
	'bombs': 'main',
	'waves': 'main',
	'bubbles': 'main'
}

const EXCLUSIVE = {
	'main': true,
	'strange': false,
	'protection': false,
	'addition': false
}

const COLOR = {
	'main': Color(1,0,0,1),
	'strange': Color(1,0,1,1),
	'protection': Color(0,1,1,1),
	'addition': Color(1,0.25,0,1)
}

func _ready():
	if not is_inside_tree():
		yield(self, 'ready')
		
	if len(random_types) > 0:
		self.set_type(random_types[randi() % len(random_types)])
	else:
		refresh_type()
	
	if tease:
		$AnimationPlayer.play('tease')
		yield($AnimationPlayer, "animation_finished")
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
	$TeleportBeam.modulate = self.get_color(type)
	
func activate():
	$CollisionShape2D.set_deferred('disabled', false)

func get_strategy(ship, distance, game_mode):
	return {"seek": 1}
	
func collect(by):
	queue_free()
	emit_signal('collected', by)

static func get_color(t):
	return COLOR[CATEGORY[t]]
	
static func is_exclusive(t):
	return EXCLUSIVE[CATEGORY[t]]
