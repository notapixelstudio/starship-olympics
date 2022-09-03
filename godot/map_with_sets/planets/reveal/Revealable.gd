tool
extends Node2D

export var texture : Texture setget set_texture
export var linked_to : NodePath

func set_texture(v):
	texture = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Sprite.texture = texture
	
func _ready():
	if linked_to:
		yield(get_tree(), "idle_frame") # wait for linked stuff to be ready
		var linked_node = get_node(linked_to)
		self.modulate = Color(1,1,1,1) if not linked_node.get_status() == TheUnlocker.HIDDEN or Engine.editor_hint else Color(0,0,0,0)
		linked_node.connect('unhid', self, '_on_linked_node_unhid')
		
func _on_linked_node_unhid():
	$AnimationPlayer.play("Reveal")
