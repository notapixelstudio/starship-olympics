extends RigidBody2D
class_name Cargo

@export var drop_distance := 64.0

var _self_scene : PackedScene
var _untouchable_by = null

func place_and_push(global_pos: Vector2, vel: Vector2, rot: float) -> void:
	global_position = global_pos + Vector2(drop_distance,0).rotated(rot)
	linear_velocity = vel
	reset_physics_interpolation() # TBD check if this suffices when https://github.com/godotengine/godot/pull/92218 is merged
	# if it suffices, re-enable physics interpolation in Shadow.tscn
	
func touched_by(toucher : Ship):
	if toucher == _untouchable_by:
		return
		
	Events.sth_loaded.emit(toucher, self)
	queue_free()

func get_texture() -> Texture:
	return %Sprite2D.texture

func hit():
	%SpriteAnimation.stop()
	%SpriteAnimation.play('Hit')

func _ready():
	_self_scene = PackedScene.new()
	_self_scene.pack(self)
	
func clone_as_new() -> Cargo:
	return _self_scene.instantiate()

func _on_body_entered(body: Node) -> void:
	#_reset_untouchable() # always reset untouchability on bouncing off sth
	
	if body is StaticBody2D:
		Events.sth_impacted.emit(self, body)
	
func set_temp_untouchable_by(untoucher) -> void:
	_untouchable_by = untoucher
	%UntouchableTimer.start()

func _on_untouchable_timer_timeout() -> void:
	_reset_untouchable()
	
func _reset_untouchable() -> void:
	_untouchable_by = null
