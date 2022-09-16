extends MarginContainer

func _ready():
	Events.connect("show_info",Callable(self,"show_banner"))
	Events.connect("hide_info",Callable(self,"hide_banner"))
	

func show_banner(what_to_show: String):
	$Timer.stop()
	if self.visible:
		return
	$AnimationPlayer.play("appear")

func hide_banner():
	# this will disappear after Timer.wait_time from the signal hide_info
	$Timer.start()


func _on_Timer_timeout():
	# now we can hide the banner
	$AnimationPlayer.play("disappear")
