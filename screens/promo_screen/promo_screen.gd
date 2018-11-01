extends "res://screens/basic_screen.gd"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var controls
		set_process_input(false)
		if event.is_action_pressed("kb1_fire"):
			controls = $Keyboard1
		elif event.is_action_pressed("kb2_fire"):
			controls = $Keyboard2
		elif event.is_action_pressed("joy1_fire"):
			controls = $Joypad1
		controls.play()
		yield(controls,"ready")
		change_scene()

func _ready():
	#Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	var joypads = Input.get_connected_joypads()

func _on_joy_connection_changed(device_id, connected):
	if Input.get_connected_joypads():
		$Control.visible = true
	else:
		$Control.visible = false
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
