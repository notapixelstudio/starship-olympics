extends RigidBody2D
class_name Cargo

@export var drop_distance := 64.0

var _self_scene : PackedScene
var _untouchable_by = null

func get_texture() -> Texture:
	return %Sprite2D.texture

func _ready():
	_self_scene = PackedScene.new()
	_self_scene.pack(self)
	
func place_and_push(global_pos: Vector2, vel: Vector2, rot: float) -> void:
	global_position = global_pos + Vector2(drop_distance,0).rotated(rot)
	linear_velocity = vel
	reset_physics_interpolation() # TBD check if this suffices when https://github.com/godotengine/godot/pull/92218 is merged
	# if it suffices, re-enable physics interpolation in Shadow.tscn
	
func clone_as_new() -> Cargo:
	var clone = _self_scene.instantiate()
	clone._self_scene = _self_scene
	return clone

func _on_body_entered(body: Node) -> void:
	#_reset_untouchable() # always reset untouchability on bouncing off sth
	
	if body is StaticBody2D:
		Events.collision.emit(self, body)
	
func touched_by(actor) -> void:
	# avoid loading a cargo twice, if we already have been loaded
	if is_queued_for_deletion():
		return
	
	if _is_untouchable_by(actor):
		return
		
	if actor.has_method('load_cargo'): # WARNING duck typing
		actor.load_cargo(self)
		queue_free()
	
func _is_untouchable_by(sth) -> bool:
	return sth == _untouchable_by

func set_temp_untouchable_by(untoucher) -> void:
	_untouchable_by = untoucher
	%UntouchableTimer.start()
	
func _on_untouchable_timer_timeout() -> void:
	_reset_untouchable()
	
func _reset_untouchable() -> void:
	_untouchable_by = null
	
func hit():
	%SpriteAnimation.stop()
	%SpriteAnimation.play('Hit')
