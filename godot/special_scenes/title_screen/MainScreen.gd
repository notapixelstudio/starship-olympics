extends BasicScreen

# TODO: We need a way to get the scene
onready var title = $TitleScreen
onready var buttons = $Buttons

export var multiplayer_scene : PackedScene
export var option_scene: PackedScene

func _on_QuitButton_pressed():
	disable_buttons()
	$Label2/AnimationPlayer.play("appear")
	global.end_game()

func _ready():
	Soundtrack.play("Lobby", true)
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	disable_buttons()
	title.initialize()
	yield(title, "entered")
	enable_buttons()
	
	
func _on_TitleScreen_option_selected():
	disable_buttons()


func _on_Options_back():
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
