extends Control

signal standoff_ready
signal reset_signal(level)

onready var anim = $AnimationPlayer

var next_level
signal finished

func _ready():
	next_level = global.level
	# connect("reset_signal", get_node('/root/Arena'), "reset")

func start():
	visible = true
	anim.play("GetReady")
	yield(anim, "animation_finished")
	anim.play("Fight")
	yield(anim, "animation_finished")
	visible = false
	emit_signal("finished")
