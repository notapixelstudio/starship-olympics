extends Node

@export var battlefield: Node2D
@export var floating_message_scene: PackedScene
@export var magnify := 1.0

func _ready():
	Events.message.connect(_on_message)
	
func _on_message(message:Variant, color:Color, global_position:Vector2) -> void:
	var floating_message = floating_message_scene.instantiate()
	floating_message.set_message(message)
	floating_message.set_color(color)
	floating_message.scale *= magnify
	floating_message.global_position = global_position
	battlefield.add_child(floating_message)
