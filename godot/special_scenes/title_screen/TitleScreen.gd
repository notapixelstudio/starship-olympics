extends Control

signal option_selected
signal entered
signal start_multiplayer

onready var animation = $Animator
onready var buttons = $Buttons

export var options_scene: PackedScene

func _ready():
	self.appear()

func appear():
	for button in buttons.get_children():
		button.disabled  = true
	animation.play("fade_in")
	yield(animation, "animation_finished")
	for button in buttons.get_children():
		button.disabled  = false
	buttons.get_child(0).grab_focus()
	
func back_from_options():
	self.appear()
	
func _on_Options_pressed():
	animation.play("fade_out")
	yield(animation, "animation_finished")
	var options: UIOptions = options_scene.instance()
	add_child(options)
	options.connect("back_at_you", self, "back_from_options")


