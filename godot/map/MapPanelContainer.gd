extends HBoxContainer

class_name MapPanelContainer

signal selection_finished

onready var tween = $Tween

func random_selection(list: Array, sel_index, loops=2, max_duration=5):
	list.shuffle()
	list.resize(min(5, len(list)))
	var total_wait: float = 0
	var duration_last_loop = max_duration * 0.8
	var first_loops = max_duration-duration_last_loop
	# each elements will have this speed for the first loops
	var fastest_wait_time = first_loops / len(list) / loops
	print("duration of last loop: " + str(duration_last_loop))
	var num_iterations = len(list)*loops +sel_index
	
	for i in range(num_iterations-1):
		# print("{i}: {what} for {miniga}".format({"i": i, "what": max(fastest_wait_time, duration_last_loop * 1/(pow(2, 1 + num_iterations-i))), "miniga":list[i%len(list)].content.get_id()}))
		var wait_time = max(fastest_wait_time, duration_last_loop * 1/(pow(4, 1 + num_iterations-i)))
		list[i%len(list)].selected = true
		yield(get_tree().create_timer(wait_time), "timeout")
		total_wait+= wait_time
		list[i%len(list)].selected = false
	print("Waited for "+ str(total_wait))
	emit_signal("selection_finished")

func choose_level(player_id: String, minigame: Minigame):
	# This will choose randonly one minigame. And animate afterwards
	print(minigame.get_id())
	var this_gamemode = minigame.game_mode
	var back_pos = Vector2(0,0)
	var back_scale = Vector2(1,1)
	var chosen_minicard
	
	var index_selection = 0
	var index = 0
	
	# Let's get che chosen minicard, in order to show the transition before the 
	# match starts
	var found = false
	var screen_width = ProjectSettings.get_setting('display/window/size/width')
	var screen_height = ProjectSettings.get_setting('display/window/size/height')

	for panel in get_children():
		if not panel is MapPanel:
			continue 
		if found:
			break
		for minicard in panel.get_minicards():
			if minicard.content.get_id() == this_gamemode.get_id() and panel.get_id() == player_id:
				index_selection = index
				back_pos = minicard.position
				back_scale = minicard.scale
				chosen_minicard = minicard
				minicard.z_index = 1000
				
				tween.interpolate_property(minicard, "global_position", minicard.global_position, Vector2(screen_width,screen_height)/2, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
				tween.interpolate_property(minicard, "scale", minicard.scale, Vector2(3,3), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
				found = true
				break
		index+=1
	
	# animation pseudo random for choosing minicard
	var minicards = get_tree().get_nodes_in_group("minicard")
	random_selection(minicards, index_selection)
	yield(self, "selection_finished")
	chosen_minicard.selected = true
	var wait_time = 0.5
	yield(get_tree().create_timer(wait_time), "timeout")
	chosen_minicard.selected = false
	if chosen_minicard.status == "locked":
		chosen_minicard.unlock()
		yield(chosen_minicard, "unlocked")
		# unlock and SAVE
		TheUnlocker.unlock_game(this_gamemode.id)
		persistance.save_game()
	
	tween.start()
	yield(tween, "tween_all_completed")
	# TODO: danger of lock
	Events.emit_signal("minigame_selected", minigame)
	yield(get_tree().create_timer(2), "timeout")
	# everything back to position
	chosen_minicard.position = back_pos
	chosen_minicard.scale = back_scale
	chosen_minicard.z_index = 0
	emit_signal("cleanup")
