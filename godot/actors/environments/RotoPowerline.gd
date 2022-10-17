tool
extends Rototile
class_name RotoPowerline

signal connected
signal disconnected
signal propagate

var placed := true

export (String, 'I', 'T', 'C', 'X') var type = 'T' setget set_type
var on := false setget set_on

func set_on(v: bool) -> void:
	on = v
	if on:
		$Line2D.self_modulate = Color(1,1,0.4)
	else:
		$Line2D.self_modulate = Color(0.1,0.1,0.1)
		
func set_type(v: String) -> void:
	type = v
	
	if not is_inside_tree():
		yield(self, "ready")
		
	match type:
		'I':
			$Line2D.points = PoolVector2Array([Vector2(-300,0),Vector2(300,0)])
		'T':
			$Line2D.points = PoolVector2Array([Vector2(-300,0),Vector2(300,0),Vector2(0,0),Vector2(0,300)])
		'C':
			$Line2D.points = PoolVector2Array([Vector2(-300,0),Vector2(-100,0),Vector2(0,100),Vector2(0,300)])
		'X':
			$Line2D.points = PoolVector2Array([Vector2(-300,0),Vector2(300,0),Vector2(0,0),Vector2(0,300),Vector2(0,-300)])
		

func _on_RotoPowerline_start_rotating():
	do_disconnect()

func _on_RotoPowerline_all_rotations_finished():
	do_connect()
	
func do_disconnect():
	placed = false
	set_on(false)
	emit_signal('disconnected', self)
	
func do_connect():
	placed = true
	emit_signal('connected', self)
	
func input_power_from(direction: Vector2):
	if not placed or on:
		return # do not propagate if not placed or already on
		
	var idir = ivec(direction.rotated(-angle))
	
	match type:
		'I':
			if idir == Vector2.UP or idir == Vector2.DOWN:
				return
		'T':
			if idir == Vector2.UP:
				return
		'C':
			if idir == Vector2.UP or idir == Vector2.RIGHT:
				return
		'X':
			pass
			
	set_on(true)
	
	match type:
		'I':
			emit_signal('propagate', self, ivec(Vector2.LEFT.rotated(angle)))
			emit_signal('propagate', self, ivec(Vector2.RIGHT.rotated(angle)))
		'T':
			emit_signal('propagate', self, ivec(Vector2.LEFT.rotated(angle)))
			emit_signal('propagate', self, ivec(Vector2.DOWN.rotated(angle)))
			emit_signal('propagate', self, ivec(Vector2.RIGHT.rotated(angle)))
		'C':
			emit_signal('propagate', self, ivec(Vector2.LEFT.rotated(angle)))
			emit_signal('propagate', self, ivec(Vector2.DOWN.rotated(angle)))
		'X':
			emit_signal('propagate', self, ivec(Vector2.LEFT))
			emit_signal('propagate', self, ivec(Vector2.DOWN))
			emit_signal('propagate', self, ivec(Vector2.RIGHT))
			emit_signal('propagate', self, ivec(Vector2.UP))
	
func power_off():
	set_on(false)

func ivec(v: Vector2) -> Vector2:
	return Vector2(int(v.x), int(v.y))
