extends Node2D


func _ready():
	#print(Input.get_joy_name(0))
	Input.add_joy_mapping("030000008f0e00000300000009010000,2In1 USB Joystick,platform:Mac OS X,a:b2,b:b1,x:b3,y:b0,back:b8,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7,", true)
	print("Entity is ", $RigidBody2D is RigidBody2D)
	print("The real Entity is ", $RigidBody2D is Entity)
	print(global.get_base_entity($Sprite))
	print(global.get_base_entity($RigidBody2D))


func _process(delta):
	# This is an example debug for controllers
	if Input.get_connected_joypads().size() > 0:
		 for i in range(16):
	      if Input.is_joy_button_pressed(0,i):
	        print("Button at " + str(i) + " pressed, should be button: " + Input.get_joy_button_string(i))
