extends BasicScreen

# TODO: We need a way to get the scene
onready var title = $CanvasLayer/TitleScreen
onready var options = $CanvasLayer/Options
onready var buttons = $CanvasLayer/Buttons
onready var canvas_layer = $CanvasLayer
onready var info = $Disclaimer

export var multiplayer_scene : PackedScene

func _on_QuitButton_pressed():
	disable_buttons()
	$Label2/AnimationPlayer.play("appear")
	global.end_game()
	#get_tree().quit()

func _ready():
	Soundtrack.play("Lobby5", true)
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	canvas_layer.remove_child(options)
	canvas_layer.remove_child(title)
	disable_buttons()
	if global.first_time:
		info.start()
		yield(info, "okay")
	canvas_layer.add_child(title)
	title.initialize()
	yield(title, "entered")
	enable_buttons()
	
	
func _on_TitleScreen_option_selected():
	canvas_layer.remove_child(title)
	disable_buttons()
	canvas_layer.add_child(options)
	options.enable_all()


func _on_Options_back():
	canvas_layer.add_child(title)
	canvas_layer.remove_child(options)
	title.initialize()
	yield(title, "entered")
	enable_buttons()


func _on_TitleScreen_start_multiplayer():
	global.campaign_mode = false
	global.send_stats("design", {"event_id":"selection:mode:campaign_mode", "value": int(false)})
	switch()
	yield(self, "finished")
	get_tree().change_scene_to(multiplayer_scene)

func disable_buttons():
	buttons.visible = false
	# disable all buttons at first
	for button in buttons.get_children():
		button.disabled = true

func enable_buttons():
	buttons.visible = true
	for button in buttons.get_children():
		button.disabled = false
		
	buttons.get_child(0).grab_focus()
	
func _on_CampaignMode_pressed():
	global.campaign_mode = true
	global.send_stats("design", {"event_id":"selection:mode:campaign_mode", "value": int(true)})
	switch()
	yield(self, "finished")
	get_tree().change_scene_to(multiplayer_scene)
	
