class_name SOLog
extends "res://addons/debugToolbox/Log.gd"


func _ready():
	super._ready()
	add_theme_font_size_override("normal_font_size", 8)
	Events.log.connect(_on_log)
	
func _on_log(message: String):
	log_line(message)
