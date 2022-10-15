extends Rototile

func _on_RotoPowerline_start_rotating():
	do_disconnect()

func _on_RotoPowerline_all_rotations_finished():
	do_connect()
	
func do_disconnect():
	$Line2D.modulate = Color(0.5,0.5,0.5)
	
func do_connect():
	$Line2D.modulate = Color(1,1,1)
