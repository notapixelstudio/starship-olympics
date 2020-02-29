extends Node
class_name BasicScreen

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor
onready var anim = $AnimationPlayer
onready var effect_sound = $EffectSound
var transitioning = false


func switch():
	if transitioning:
		return
	transitioning = true
	anim.play("fade")
	# initialize whatever scene
	yield(anim, "animation_finished")
	transitioning = false
	emit_signal("finished")
	
