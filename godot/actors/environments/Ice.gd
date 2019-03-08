extends Node2D

signal entered
func _on_Area2D_body_entered(body):
	emit_signal("entered", self, body)
	
signal exited
func _on_Area2D_body_exited(body):
	emit_signal("exited", self, body)
	