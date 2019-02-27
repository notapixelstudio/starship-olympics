extends Node2D


func _ready():
	#print(Input.get_joy_name(0))
	#Input.add_joy_mapping("030000008f0e00000300000009010000,2In1 USB Joystick,+leftx:h0.2,+lefty:h0.4,-leftx:h0.8,-lefty:h0.1,a:b2,b:b1,back:b8,dpdown:+a1,dpleft:-a0,dpright:+a0,dpup:-a1,leftshoulder:b4,leftstick:b10,lefttrigger:b6,rightshoulder:b5,rightstick:b11,righttrigger:b7,rightx:a2,righty:a3,start:b9,x:b3,y:b0,platform:Mac OS X,", true)
	print(get_node("/root/AudioServer"))
	print(AudioServer)
	global.audio_on = true


func _process(delta):
	# This is an example debug for controllers
	if Input.get_connected_joypads().size() > 0:
		 for i in range(16):
	      if Input.is_joy_button_pressed(0,i):
	        print("Button at " + str(i) + " pressed, should be button: " + Input.get_joy_button_string(i))
