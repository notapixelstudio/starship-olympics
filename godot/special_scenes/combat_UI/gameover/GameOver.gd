extends Control

onready var animator = $Animator
onready var buttons = $Buttons
onready var back_to_menu_button = $Buttons/Map
onready var continue_button = $Buttons/Continue

signal pressed_continue
signal show_arena
signal hide_arena

export var sure_scene: PackedScene

func _ready():
	set_process_unhandled_input(false)
	$"%LeaderBoard".setup()
	# a match has ended, save the game
	#persistance.save_game_as_latest()

func _on_Continue_pressed():
	get_tree().paused = false
	Events.emit_signal("continue_after_game_over", global.session.is_over())

func _on_Quit_pressed():
	global.end_execution()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		self.visible = true
		emit_signal("hide_arena")
		set_process_unhandled_input(false)
		yield(get_tree().create_timer(0.5), "timeout")
		# grab focus on first button visible
		for button in buttons.get_children():
			if button.visible:
				button.grab_focus()
				break


func _show_arena():
	set_process_unhandled_input(true)
	self.visible = false
	emit_signal("show_arena")


func _on_Map_pressed():
	var confirm = sure_scene.instance()
	for button in buttons.get_children():
		button.focus_mode = Control.FOCUS_NONE
	add_child(confirm)
	confirm.setup("map")
	yield(confirm, "choice_selected")
	if confirm.choice:
		get_tree().paused = false
		Events.emit_signal("nav_to_map")
	else:
		for button in buttons.get_children():
			button.focus_mode = Control.FOCUS_ALL
	confirm.queue_free()
	


func _on_LeaderBoard_animation_over():
	if global.demo:
		get_tree().paused = false
		Events.emit_signal("nav_to_character_selection")
		return 
	$"%Buttons".visible = true
	
	#TODO: what do we do in case of DRAW of session? Will ignore it for now
	if global.session.is_over():
		Soundtrack.play('SessionOver', true)
		back_to_menu_button.visible=false
	
	for button in $"%Buttons".get_children():
		if button.visible:
			button.grab_focus()
			break
