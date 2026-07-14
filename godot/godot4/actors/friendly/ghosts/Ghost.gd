extends Area2D
class_name Ghost

var _ship_to_follow : Ship = null
var _speed := 1000.0

var _min_distance := 300.0

func _ready() -> void:
	%AnimationPlayer.play("default")
	%AnimationPlayer.advance(randf())

func touched_by(ship:Ship) -> void:
	Events.ghost_touched.emit(self, ship)

func is_roaming_free() -> bool:
	return _ship_to_follow == null

func follow(ship: Ship) -> void:
	_ship_to_follow = ship
	modulate = ship.get_color()
	
func _physics_process(delta: float) -> void:
	if _ship_to_follow == null:
		return
		
	if global_position.distance_to(_ship_to_follow.global_position) < _min_distance:
		return
		
	var movement = global_position.direction_to(_ship_to_follow.global_position)*_speed*delta
	global_position += movement
	
	# flip according to direction of movement
	if movement.x > 0:
		scale.x = 1
	elif movement.x < 0:
		scale.x = -1

func get_type():
	return %Sprite2D.texture

func _on_area_entered(area: Area2D) -> void:
	if not area is Ghost:
		return
		
	# avoid duplicate events
	#if area.get_rid() > get_rid():
	#	return
	
	if get_type() == area.get_type():
		Events.ghosts_matched.emit(self, area)
