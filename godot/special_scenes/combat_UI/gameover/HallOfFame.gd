extends Control

export var champion_scene : PackedScene

func cleanup_datetime_str(datetime_str: String):
	return datetime_str.replace("T", " ")

func _ready():
	$"%Label".queue_free() 
	$"%WinnerBanner".queue_free()
	var data = global.read_file_by_line(InfoChampion.PATH_FILE_CHAMPIONS)
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

func _input(event):
	if event.is_action_pressed("confirm"):
		Events.emit_signal("nav_to_map")
		set_process_input(false)
		queue_free()
