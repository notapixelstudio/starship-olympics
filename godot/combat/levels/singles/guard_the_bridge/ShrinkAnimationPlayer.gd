extends AnimationPlayer

var state

func _ready():
	set_process(false)
	
func start():
	set_process(true)
	state = 'shrinking'
	play("Shrink")
	
func _process(delta):
	if state == 'growing' and len(get_parent().get_overlapping_bodies()) > 0:
		state = 'shrinking'
		play("Shrink")
		
	if state == 'shrinking' and len(get_parent().get_overlapping_bodies()) <= 0:
		state = 'growing'
		play_backwards("Shrink")
		
