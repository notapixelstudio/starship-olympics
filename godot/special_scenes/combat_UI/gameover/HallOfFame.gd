extends Control

export var champion_scene : PackedScene

func cleanup_datetime_str(datetime_str: String):
	return datetime_str.replace("T", " ")

func _ready():
	
	var data = global.read_file_by_line(InfoChampion.PATH_FILE_CHAMPIONS)
	if data.empty():
		for i in range(30):
			var l = $"%Label".duplicate()
			var champ_scene = $"%WinnerBanner".duplicate()
			$"%SessionWon".add_child(l)
			$"%SessionWon".add_child(champ_scene)
	else:
		$"%Label".queue_free() 
		$"%WinnerBanner".queue_free()
	data.invert()
	for champion in data:
		var champ_info := InfoChampion.new()
		champ_info.session_info = champion.session_info
		champ_info.player = champion.player
		
		var champ_scene = champion_scene.instance()
		champ_scene.set_player(champ_info)
		var l = $"%Label".duplicate()
		l.text = cleanup_datetime_str(champ_info.session_info.timestamp)
		$"%SessionWon".add_child(l)
		$"%SessionWon".add_child(champ_scene)
	yield(get_tree(), "idle_frame")
	$"%ScrollContainer".scroll_vertical = pow(10, 4)
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property($"%ScrollContainer", 'scroll_vertical', 0, 4)

func _input(event):
	if event.is_action_pressed("confirm"):
		Events.emit_signal("nav_to_map")
		set_process_input(false)
		queue_free()
