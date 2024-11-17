class_name Treasure
extends RigidBody2D

@export var collectable := true : set = set_collectable
@export var solid := true
@export var points := 1
@export var treasure_picked_scene : PackedScene
@export var appear_scene : PackedScene
@export var outline_texture : Texture

signal collected(PhysicsBody2D, Treasure)

func set_collectable(v: bool) -> void:
	collectable = v
	update_solid()

func is_collectable() -> bool:
	return collectable
	
func get_points() -> int:
	return points

func set_texture(v: Texture) -> void:
	%Sprite2D.texture = v
	
func get_texture() -> Texture:
	return %Sprite2D.texture
	
func _ready():
	update_solid()
	
func update_solid():
	# ship bodies should push diamonds iff not collectable
	set_collision_mask_value(1, not collectable and solid)
	
func touched_by(toucher : Ship):
	if not collectable:
		return
		
	collected.emit(toucher, self)
	Events.sth_collected.emit(toucher, self)
	
	# drop a treasure picked effect on parent
	var picked_effect = treasure_picked_scene.instantiate()
	picked_effect.set_texture(outline_texture)
	picked_effect.global_position = global_position
	get_parent().add_child(picked_effect)
	
	queue_free()

func hit():
	%SpriteAnimation.stop()
	%SpriteAnimation.play('Hit')
	
func shine():
	%SpriteAnimation.stop()
	%SpriteAnimation.play('Shine')
	
func disable_collisions() -> void:
	%CollisionShape2D.disabled = true
	
func enable_collisions() -> void:
	%CollisionShape2D.disabled = false

func get_sfx_player() -> AudioStreamPlayer2D:
	return %AudioStreamPlayer2D
	
func create_appear_effect() -> Node2D:
	var appear = appear_scene.instantiate()
	appear.set_texture(get_appear_texture())
	return appear
	
func get_appear_texture() -> Texture:
	return outline_texture
