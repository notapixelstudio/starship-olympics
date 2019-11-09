extends BasicScreen

# TODO: We need a way to get the scene
onready var title = $TitleScreen
onready var options = $Options
onready var buttons = $Buttons

export var multiplayer_scene : PackedScene

func _on_QuitButton_pressed():
	global.end_game()
	#get_tree().quit()

func _ready():
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	remove_child(options)
	disable_buttons()
	yield(title, "entered")
	enable_buttons()
	
	
func _on_TitleScreen_option_selected():
	remove_child(title)
	disable_buttons()
	add_child(options)
	options.enable_all()


func _on_Options_back():
	add_child(title)
	remove_child(options)
	title.initialize()
	yield(title, "entered")
	enable_buttons()


func _on_TitleScreen_start_multiplayer():
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
	for button in $Buttons.get_children():
		button.disabled = false
	buttons.get_child(0).grab_focus()
	
