extends Panel

var count = 0
var time = 0.0
onready var fps = get_node("VBoxContainer/FPS")
onready var elapsed = get_node("VBoxContainer/elapsed_time")

func _process(delta):
	time += delta
	if time < 1.0:
		count += 1
	else:
		fps.text = "FPS: "+str(count)
		count = 0
		time = 0.0
	
	elapsed.text = "time: " + str(analytics.this_elapsed_time)
