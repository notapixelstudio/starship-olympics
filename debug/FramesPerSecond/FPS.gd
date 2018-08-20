extends Label

var count = 0
var time = 0.0

func _process(delta):
	time += delta
	if time < 1.0:
		count += 1
	else:
		text = "FPS: "+str(count)
		count = 0
		time = 0.0
