class_name Treasure
extends RigidBody2D

@export var collectable := true
@export var points := 1
@export var treasure_picked_scene : PackedScene

func get_points() -> int:
	return points

func set_texture(v: Texture) -> void:
	%Sprite2D.texture = v
	
func get_texture() -> Texture:
	return %Sprite2D.texture
	
func touched_by(toucher : Ship):
	if not collectable:
		return
		
	Events.sth_collected.emit(toucher, self)
	
	# drop a treasure picked effect on parent
	var picked_effect = treasure_picked_scene.instantiate()
	picked_effect.set_texture(get_texture())
	picked_effect.global_position = global_position
	get_parent().add_child(picked_effect)
	
	queue_free()
