extends Control

signal option_selected

@onready var animation = $Animator
@onready var buttons = $Buttons

@export var options_scene: PackedScene
@export var local_multi_scene: PackedScene
@export var credits_scene: PackedScene
@export var hall_of_fame_scene: PackedScene

func _ready():
	for button in $Buttons.get_children():
		button.connect("focus_entered", Callable(self, '_on_button_focus_entered').bind(button))
		button.connect("focus_exited", Callable(self, '_on_button_focus_exited').bind(button))
	self.appear()

func appear():
	disable_buttons()
	animation.play("fade_in")
	await animation.animation_finished
	enable_buttons()
	
	# check if continue should be enabled
	var data = global.read_file("user://games/latest.json")
	var parsed_data = null
	if data:
		var test_json_conv = JSON.new()
		test_json_conv.parse(data)
		parsed_data = test_json_conv.get_data()
	$"%Continue".disabled = parsed_data == null or parsed_data.is_empty()
	
	for button in buttons.get_children():
		if button.visible and not button.disabled:
			button.grab_focus()
			break
	
func back_from_options():
	self.appear()
	
func _on_Options_pressed():
	animation.play("fade_out")
	await animation.animation_finished
	disable_buttons()
	var options = options_scene.instantiate()
	add_child(options)
	options.connect("back_at_you", Callable(self, "back_from_options"))

func _on_Fight_pressed():
	# this is a new game, delete the saved one
	persistance.delete_latest_game()
	get_tree().change_scene_to_packed(local_multi_scene)

func _on_QuitButton_pressed():
	global.end_execution()

func disable_buttons():
	buttons.visible = false
		
func enable_buttons():
	buttons.visible = true

func _on_button_focus_entered(button):
	if button.disabled and button.has_node('Lock'):
		button.get_node('Lock').visible = true
	var tooltip = $Tooltips.get_node(button.name) 
	if tooltip != null:
		tooltip.modulate = Color(1,1,1,1)
	
func _on_button_focus_exited(button):
	if button.disabled and button.has_node('Lock'):
		button.get_node('Lock').visible = false
	var tooltip = $Tooltips.get_node(button.name) 
	if tooltip != null:
		tooltip.modulate = Color(1,1,1,0)

func _on_Continue_pressed():
	get_tree().change_scene_to_packed(local_multi_scene)

func _on_Credits_pressed():
	get_tree().change_scene_to_packed(credits_scene)

func _on_HallOfFame_pressed():
	print("loading")
	get_tree().change_scene_to_packed(hall_of_fame_scene)
