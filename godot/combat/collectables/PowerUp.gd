tool

extends RigidBody2D

class_name PowerUp

export (String, 'shield', 'shields', 'plate', 'skin', 'magnet', 'snake', 'kamikaze', 'sword', 'scythe', 'flail', 'miniball_gun', 'rocket_gun', 'spike_gun', 'bomb', 'wave_gun', 'bubble_gun', 'drill') var type = 'shield' setget set_type
export var appear = true
export var tease = false
export var random_types = []

signal collected

const CATEGORY = {
	'shield': 'protection',
	'shields': 'protection',
	'plate': 'protection',
	'skin': 'protection',
	'magnet': 'protection',
	
	'snake': 'strange',
	'kamikaze': 'strange',
	
	'sword': 'addition',
	'scythe': 'addition',
	'flail': 'addition',
	
	'rocket_gun': 'weapon',
	'miniball_gun': 'weapon',
	'spike_gun': 'weapon',
	'bomb': 'weapon',
	'wave_gun': 'weapon',
	'bubble_gun': 'weapon',
	'drill': 'weapon'
}

const EXCLUSIVE = {
	'weapon': true,
	'strange': false,
	'protection': false,
	'addition': false
}

const COLOR = {
	'weapon': Color(1,0,0,1),
	'strange': Color(1,0,1,1),
	'protection': Color(0.5,1,1,1),
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
	if not Engine.editor_hint:
		$CollisionShape2D.set_deferred('disabled', false)

func get_strategy(ship, distance, game_mode):
	return {"seek": 1}
	
func collect(by):
	queue_free()
	emit_signal('collected', by)

func has_category(category: String) -> bool:
	return CATEGORY[type] == category

static func get_color(t):
	return COLOR[CATEGORY[t]]
	
static func is_exclusive(t):
	return EXCLUSIVE[CATEGORY[t]]
