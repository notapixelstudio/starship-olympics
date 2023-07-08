@tool
extends Node2D

@export var texture : Texture2D: set = set_texture
@export var linked_to : NodePath

func set_texture(v):
	texture = v
	if not is_inside_tree():
		await self.ready
	$Sprite2D.texture = texture
	
func _ready():
	if linked_to:
		await get_tree().idle_frame # wait for linked stuff to be ready
		var linked_node = get_node(linked_to)
		self.modulate = Color(1,1,1,1) if not linked_node.get_status() == TheUnlocker.HIDDEN or Engine.is_editor_hint() else Color(0,0,0,0)
		linked_node.connect('unhid', Callable(self, '_on_linked_node_unhid'))
		
func _on_linked_node_unhid():
	$AnimationPlayer.play("Reveal")
