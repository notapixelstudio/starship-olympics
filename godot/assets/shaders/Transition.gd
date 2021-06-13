extends Node

signal transitioned 
onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("fade_to_normal")
	
func transition():
	anim_player.play("fade_to_color")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_to_color":
		emit_signal("transitioned")
		anim_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		print("transitioned")
