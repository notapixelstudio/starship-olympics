extends Control

signal standoff
signal standoff_ready
signal reset_signal(level)

onready var close_button = get_node("menu_button/close_button")
onready var back_to_menu = get_node("menu_button/back_to_menu")

var next_level

func _ready():
	next_level = global.level

	$Standoff.visible = false
	for player in global.scores:
		var container = preload("res://screens/game_screen/PlayerContainerDeath.tscn").instance()
		container.p_name = player
		container.name = player
		var i = load("res://actors/"+global.chosen_species[player]+"_ship_plain.png")
		
		for life in global.scores[player]:
			var l = load("res://screens/game_screen/life_rect.tscn").instance()
			l.set_texture(i)
			container.get_node("NinePatchRect/Container").add_child(l)
		$VBoxContainer.add_child(container)
	connect("reset_signal", get_node('/root/Arena'), "reset")
	close_button.disabled = true
	

# TODO: that timeout has to be an animation
func update_score():
	get_tree().paused=true
	visible = true
	
	$Standoff.visible = false
	$elapsed_time.text = "elapsed time: " + str(analytics.this_elapsed_time) + "s"
	var guys = $VBoxContainer.get_children()
	# animation for the life that ... dies
	yield(get_tree().create_timer(0.5), "timeout")
	var lives = 0
	for player in guys:
		lives = player.get_life_count()
		while(global.scores[player.p_name] < lives):
			player.remove_life()
			lives = player.get_life_count()
		yield(get_tree().create_timer(0.1), "timeout")

	# check in order to change level according to players alive
	var alive_players = 0
	if global.gameover:
		for p in global.scores:
			if global.scores[p] > 0:
				alive_players += 1
		if alive_players > 1 :
			global.gameover = false
			next_level = str(alive_players) + "players.tscn"
			
		var all_lives = global.scores.values()
		all_lives.sort()
	if global.standoff:
		$Standoff.visible = true
		ready_for_standoff()
		yield(self, "standoff_ready")
		global.gameover = false
		global.standoff = false
		
	close_button.disabled=false
	close_button.grab_focus()

func ready_for_standoff():
	var i = 0
	yield(get_tree().create_timer(0.7), "timeout")
	for player in global.scores:
		var container = $VBoxContainer.get_child(i)
		yield(get_tree().create_timer(0.1), "timeout")
		container.add_life()
		global.scores[player] += 1 
		i+=1
	emit_signal("standoff_ready")
	
func _on_close_button_pressed():
	
	get_tree().paused=false
	hide()
	
	if global.gameover:
		get_tree().change_scene_to(load('res://screens/gameover_screen/GameOver.tscn'))
	else:
		emit_signal("reset_signal", next_level)


func _on_Timer_timeout():
	pass
	


func _on_back_to_menu_pressed():
	get_tree().paused=false
	hide()
	
	get_tree().change_scene(global.from_scene)
