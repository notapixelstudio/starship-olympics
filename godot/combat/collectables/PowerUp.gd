tool

extends RigidBody2D

class_name PowerUp

export (String, 'shield') var type = 'shield'
export var appear = true

signal collected

func _ready():
	if not is_inside_tree():
		yield(self, 'ready')
	
	$Sprite.texture = load('res://assets/sprites/powerups/'+type+'.png')
	
	if appear:
		$AnimationPlayer.play('AppearFhuFhuFhu')
		yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play('idle')
	activate()
	
func activate():
	$CollisionShape2D.disabled = false

func get_strategy(ship, distance, game_mode):
	return {"seek": 1}
	
func collect(by):
	queue_free()
	emit_signal('collected', by)
