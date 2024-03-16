class_name TestChamberLog
extends "res://addons/debugToolbox/Log.gd"


func _ready():
	super._ready()
	Events.log.connect(_on_log)
	
func _on_log(message: String):
	log_line(message)
