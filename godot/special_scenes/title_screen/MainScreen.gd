extends "res://special_scenes/BasicScreen.gd"

# TODO: We need a way to get the scene
var this_path="res://screens/main_screen/main_screen.tscn"


func _on_Save_pressed():
	persistance.save_game()
	if persistance.load_game():
		$VBoxContainer/Save/Label.text = "good job!"
		global.reset()

func _on_joy_connection_changed(device_id, connected):
    if connected:
        print(Input.get_joy_name(device_id))
    else:
        print("Keyboard")




func _on_QuitButton_pressed():
	get_tree().quit()
