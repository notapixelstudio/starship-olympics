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
	
	#if appear:
	#	$AnimationPlayer.play('AppearFuhfuhfuh')
	#	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play('idle')

func get_strategy(ship, distance, game_mode):
	return {"seek": 1}
	
func collect(by):
	queue_free()
	emit_signal('collected', by)
