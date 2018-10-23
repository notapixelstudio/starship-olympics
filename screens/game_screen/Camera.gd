extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
# Called every time the node is added to the scene.
	# Initialization here
	pass

# https://github.com/henriiquecampos/openjam2018
func tween_camera(new_camera):
	if not current:
		return
	get_tree().paused = true
	$tween.interpolate_property(self, "global_position", global_position, new_camera.global_position,
		2.0, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	$tween.interpolate_property(self, "zoom", zoom, new_camera.zoom, 2.0,
		Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		
	$tween.start()
	yield($tween, "tween_completed")
	current = false
	get_tree().paused = false
	new_camera.current = true