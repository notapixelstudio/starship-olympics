extends "res://screens/basic_screen.gd"

# TODO: We need a way to get the scene
var this_path="res://screens/main_screen/main_screen.tscn"

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	global.from_scene = this_path
	$VBoxContainer.add_constant_override("separation", 6)
	$VBoxContainer/StartCPU.grab_focus()
	persistance.load_game()
	global.reset()
	
	#background music
	bgm.stream = load("res://assets/sounds/soundtracks/273300__frankum__electronic-base-and-pop-guitar.wav")
	if !bgm.is_playing():
		bgm.play()

	
func _on_Credits_pressed():
	change_scene("res://screens/credit_screen/credit_screen.tscn")

func _on_StartCPU_pressed():
	global.enemy = "CPU"
	change_scene()

func _on_StartHuman_pressed():
	global.enemy = "Human"
	change_scene()


func _on_Save_pressed():
	persistance.save_game()
	if persistance.load_game():
		$VBoxContainer/Save/Label.text = "good job!"
		global.reset()


func _on_Options_pressed():
	change_scene("res://screens/option_screen/OptionScreen.tscn")

func _on_joy_connection_changed(device_id, connected):
    if connected:
        print(Input.get_joy_name(device_id))
    else:
        print("Keyboard")
