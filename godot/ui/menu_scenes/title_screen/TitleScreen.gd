extends Control

signal option_selected

@onready var animation = $Animator
@onready var buttons = $Buttons

@export var options_scene: PackedScene
@export var local_multi_scene: PackedScene

func _ready():
	for button in $Buttons.get_children():
		button.connect("focus_entered",Callable(self,'_on_button_focus_entered').bind(button))
		button.connect("focus_exited",Callable(self,'_on_button_focus_exited').bind(button))
	self.appear()

func appear():
	disable_buttons()
	animation.play("fade_in")
	await animation.animation_finished
	enable_buttons()
	buttons.get_child(0).grab_focus()
	
func back_from_options():
	self.appear()
	
func _on_Options_pressed():
	animation.play("fade_out")
	await animation.animation_finished
	disable_buttons()
	var options = options_scene.instantiate()
	add_child(options)
	options.connect("back_at_you",Callable(self,"back_from_options"))

func _on_Fight_pressed():
	get_tree().change_scene_to_packed(local_multi_scene)

func _on_QuitButton_pressed():
	global.end_execution()
	Button

func disable_buttons():
	buttons.visible = false
		
func enable_buttons():
	buttons.visible = true

func _on_button_focus_entered(button):
	if button.disabled:
		button.get_node('Lock').visible = true
	$Tooltips.get_node(button.name).modulate = Color(1,1,1,1)
	
func _on_button_focus_exited(button):
	if button.disabled:
		button.get_node('Lock').visible = false
	$Tooltips.get_node(button.name).modulate = Color(1,1,1,0)
