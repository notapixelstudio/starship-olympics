extends PopupPanel

signal reset_signal
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	for player in global.scores:
		var container = preload("res://screens/game_screen/PlayerContainerDeath.tscn").instance()
		container.p_name = player
		var i = load("res://actors/"+global.species[global.chosen_species[player]]+"_ship.png")
		for life in global.scores[player]:
			var l = load("res://screens/game_screen/life_rect.tscn").instance()
			l.set_texture(i)
			container.get_node("NinePatchRect/HBoxContainer").add_child(l)
		$VBoxContainer.add_child(container)
	connect("reset_signal", get_node('/root/Arena'), "reset")
	yield(get_tree().create_timer(1.0), "timeout")
	$close_button.grab_focus()
	

# TODO: that timeout has to be an animation
func update_score():
	var guys = $VBoxContainer.get_children()
	yield(get_tree().create_timer(0.5), "timeout")
	for player in guys:
		var lives = player.get_life_count()
		while(global.scores[player.p_name] < lives):
			player.remove_life()
			lives = player.get_life_count()
		
		
func _on_close_button_pressed():
	get_tree().paused=false
	hide()
	if global.gameover:
		get_tree().change_scene_to(load('res://screens/gameover_screen/GameOver.tscn'))
	else:
		emit_signal("reset_signal")
