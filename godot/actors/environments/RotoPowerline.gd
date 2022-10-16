tool
extends Rototile

export (String, 'I', 'T', 'C') var type = 'T' setget set_type
var on := false setget set_on

func set_on(v: bool) -> void:
	on = v
	if on:
		$Line2D.modulate = Color(1,1,0.4)
	else:
		$Line2D.modulate = Color(0,0,0)
		
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
		

func _on_RotoPowerline_start_rotating():
	do_disconnect()

func _on_RotoPowerline_all_rotations_finished():
	do_connect()
	
func do_disconnect():
	set_on(false)
	
func do_connect():
	set_on(true)
	
