extends EditorPlugin
@tool

func _enter_tree():
	add_autoload_singleton("GameAnalytics", "res://addons/Godot-GameAnalytics/GameAnalytics.gd")

func _exit_tree():
	remove_autoload_singleton("GameAnalytics")
