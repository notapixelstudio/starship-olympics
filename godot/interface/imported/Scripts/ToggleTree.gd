extends AnimationTree

func _ready():
	self.active = true
	self['parameters/playback'].start('ToggleOff')

func _on_Toggle_toggled(button_pressed):
	if button_pressed:
		self['parameters/playback'].travel('ToggleOn')
	else: 
		self['parameters/playback'].travel('ToggleOff')
