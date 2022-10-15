extends Rototile

var on := false setget set_on

func set_on(v: bool) -> void:
	on = v
	if on:
		$Line2D.modulate = Color(1,1,1)
	else:
		$Line2D.modulate = Color(0,0,0)

func _on_RotoPowerline_start_rotating():
	do_disconnect()

func _on_RotoPowerline_all_rotations_finished():
	do_connect()
	
func do_disconnect():
	set_on(false)
	
func do_connect():
	set_on(true)
	
