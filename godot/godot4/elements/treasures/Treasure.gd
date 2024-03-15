@tool
class_name Treasure
extends RigidBody2D

@export var collectable := true
@export var points := 1
@export var texture : Texture : set = set_texture
@export var treasure_picked_scene : PackedScene

func set_texture(v: Texture) -> void:
	texture = v
	%Sprite2D.texture = v
	
func touched_by(toucher : Ship):
	if not collectable:
		return
		
	Events.sth_collected.emit(toucher, self)
	
	# drop a treasure picked effect on parent
	var picked_effect = treasure_picked_scene.instantiate()
	picked_effect.set_texture(texture)
	picked_effect.global_position = global_position
	get_parent().add_child(picked_effect)
	
	queue_free()
