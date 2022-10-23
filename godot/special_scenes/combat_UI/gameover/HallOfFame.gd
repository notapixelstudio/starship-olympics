extends Control

class_name HallOfFame

export var champion_scene : PackedScene
export var add_champion := false

var champion_info = InfoChampion

func _ready():
	$"%WinnerBanner".queue_free()
	set_process_input(false)
	var data = global.read_file_by_line(InfoChampion.PATH_FILE_CHAMPIONS)
	if data.empty():
		for i in range(30):
			var champ_scene = champion_scene.instance()
			var info_player := InfoPlayer.new()
			var champ = InfoChampion.new()
			info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
			champ.player = info_player.to_dict()
			champ.session_info = {"timestamp": global.datetime_to_str(OS.get_datetime(true))}
			champ_scene.set_player(champ)
			$"%SessionWon".add_child(champ_scene)
	
	data.invert()
	for champion in data:
		var champ_info := InfoChampion.new()
		champ_info.session_info = champion.session_info
		champ_info.player = champion.player
		var champ_scene = champion_scene.instance()
		champ_scene.set_player(champ_info)
		$"%SessionWon".add_child(champ_scene)
		
	yield(get_tree(), "idle_frame")
	$"%ScrollContainer".scroll_vertical = pow(10, 4)
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property($"%ScrollContainer", 'scroll_vertical', 0, 1+ $"%SessionWon".get_child_count()%3)
	yield(tween, "finished")
	if self.get_parent() == get_tree().get_root():
		var info_player := InfoPlayer.new()
		var champ = InfoChampion.new()
		info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
		champ.player = info_player.to_dict()
		champ.session_info = {"timestamp": global.datetime_to_str(OS.get_datetime(true))}
		self.set_champion(champ)
	add_champion_to_scene()
	
func naming_champions():
	print("Everything is set")
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("confirm"):
		Events.emit_signal("nav_to_map")
		set_process_input(false)
		queue_free()

func set_champion(champion: InfoChampion):
	champion_info = champion
	
func add_champion_to_scene():
	var champ_scene = champion_scene.instance()
	champ_scene.set_player(champion_info)
	$"%SessionWon".add_child(champ_scene)
	$"%SessionWon".move_child(champ_scene, 0)
	# you can write your name now
	var this_champion = $"%SessionWon".get_child(0)
	this_champion.insert_name()
	this_champion.connect("champion_has_a_name", self, "naming_champions")
