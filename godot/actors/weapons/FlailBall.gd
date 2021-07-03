extends RigidBody2D

signal bump

func _ready():
	# FIXME? this could be enforced by the trait
	Events.emit_signal('bumper_created', self)
