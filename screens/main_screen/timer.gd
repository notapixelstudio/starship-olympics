extends Timer
const DURATIONS = [0.25, 0.5, 1.0]
const RESTS = [2.0, 3.0, 4.0, 5.0, 6.0]
var rest = RESTS[0]
func _ready():
	randomize()
	connect("timeout", self, "change_duration")
	start()
	
func change_duration():
	get_parent().duration = DURATIONS[randi()%DURATIONS.size()]
	rest = RESTS[randi()%RESTS.size()]
	set_wait_time(rest)
	start()
	yield(self, "timeout")
	get_parent().sing()