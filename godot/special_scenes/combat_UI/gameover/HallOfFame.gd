extends Control

class_name HallOfFame

const menu_scene = "res://ui/menu_scenes/title_screen/MainScreen.tscn"

@export var champion_scene : PackedScene
@export var add_champion := false
@export var auto_quit := true

var champion_info : Dictionary

func _ready():
	$"%WinnerBanner".queue_free()
	set_process_input(false)
	# var data = global.read_file_by_line(InfoChampion.PATH_FILE_CHAMPIONS)
	var data := []
	if data.is_empty():
		# var fake_session = TheSession.new()
		for i in range(3):
			var champ_scene = champion_scene.instantiate()
			var players = []
			for n in range(4):
				var player = Player.new()
				player.species = Settings.get_species('mantiacs_1')
				players.append(player)
			
			champ_scene.set_banner({"team": {"name": "Goologollo", "players": players}, "score": 250.20})
			$"%SessionWon".add_child(champ_scene)
	
	data.reverse()
	for champion in data:
		pass
		"""
		var champ_info := InfoChampion.new()
		champ_info.session_info = champion.session_info
		champ_info.player = champion.player
		var champ_scene = champion_scene.instantiate()
		champ_scene.set_player(champ_info)
		$"%SessionWon".add_child(champ_scene)
		"""
	
	"""
	# fakely add a new champion, for debug
	if self.get_parent() == get_tree().get_root() and add_champion:
		var info_player := InfoPlayer.new()
		var champ = InfoChampion.new()
		info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
		champ.player = info_player.to_dict()
		var fake_session = TheSession.new()
		champ.session_info = fake_session.to_dict()
		self.set_champion(champ)
	"""
	
	# yield(get_tree(), "idle_frame")
	
	if add_champion:
		add_champion_to_scene()
	
	
	$"%ScrollContainer".scroll_vertical = pow(10, 4)
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property($"%ScrollContainer", 'scroll_vertical', 0, 1 + $"%SessionWon".get_child_count()%3)
	await tween.finished
	if not add_champion:
		$ScrollContainer.get_child(0).grab_focus()
		set_process_input(true)
	
	
func naming_champions():
	set_process_input(true)
	$VBoxContainer/Label3.visible=true
	
func _input(event):
	if auto_quit and event.is_action_pressed("ui_accept"):
		Events.emit_signal("continue_after_session_ended")
		set_process_input(false)
		if self.get_parent() == get_tree().get_root():
			get_tree().change_scene_to_file(menu_scene)
		queue_free()
	if event.is_action_pressed("ui_down"):
		$"%ScrollContainer".scroll_vertical += 30 
	if event.is_action_pressed("ui_up"):
		$"%ScrollContainer".scroll_vertical -= 30 
		
func set_champion(champion: Dictionary):
	champion_info = champion
	
func add_champion_to_scene():
	var champ_scene = champion_scene.instantiate()
	if champion_info==null:
		champion_info = fake_champion()
	await get_tree().process_frame
	champ_scene.set_banner(champion_info)
	$"%SessionWon".add_child(champ_scene)
	$"%SessionWon".move_child(champ_scene, 0)
	# you can write your name now
	var this_champion = $"%SessionWon".get_child(0)
	this_champion.insert_name()
	this_champion.connect("champion_has_a_name", Callable(self, "naming_champions"))

func fake_champion() -> Dictionary:
	return {"player": {}}
	"""
	var info_player := InfoPlayer.new()
	var champ = InfoChampion.new()
	info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
	champ.player = info_player.to_dict()
	var fake_session = TheSession.new()
	champ.session_info = fake_session.to_dict()
	return champ
	"""
	
