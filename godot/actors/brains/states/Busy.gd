extends BrainState
export var wait_msec := 1000

var enter_time

func think():
	if Time.get_ticks_msec() - enter_time >= wait_msec:
		transition_to('Idle')

func enter():
	enter_time = Time.get_ticks_msec()
	get_host().blink_filament()

func exit():
	get_host().stop_blink_filament()
