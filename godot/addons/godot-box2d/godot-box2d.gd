@tool
extends EditorPlugin


func _enter_tree():
    ProjectSettings.set_setting("physics/2d/physics_engine", "Box2D")


func _exit_tree():
    ProjectSettings.set_setting("physics/2d/physics_engine", "DEFAULT")
