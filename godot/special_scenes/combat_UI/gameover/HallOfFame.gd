extends Control

class_name HallOfFame

const menu_scene = "res://ui/menu_scenes/title_screen/MainScreen.tscn"

@export var champion_scene : PackedScene
@export var add_champion := false
@export var auto_quit := true
@export var session : Session : set = set_session

func set_session(v:Session) -> void:
	session = v

var new_score : Scores

func _ready():
	Events.new_entry_hall_of_fame.connect(store_new_entry)
	$"%WinnerBanner".queue_free()
	set_process_input(false)
	var data = get_hall_of_fame(session.get_last_score())
	
	data.sort_custom(func(a,b): return a["score"] < b["score"])
	
	for champion in data:
		var champ_scene: WinnerBanner = champion_scene.instantiate()
		await get_tree().process_frame
		champ_scene.set_banner(champion)
		$"%SessionWon".add_child(champ_scene)
		$"%SessionWon".move_child(champ_scene, 0)
		# you can write your name now
		var this_champion = $"%SessionWon".get_child(0)
		# this_champion.insert_name()
		
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
		
func set_new_scores(score: Scores):
	new_score = score
	
func add_champion_to_scene():
	var champ_scene: WinnerBanner = champion_scene.instantiate()
	if new_score==null:
		new_score = fake_new_score()
	await get_tree().process_frame
	champ_scene.set_banner(new_score.to_dictionary())
	$"%SessionWon".add_child(champ_scene)
	$"%SessionWon".move_child(champ_scene, 0)
	# you can write your name now
	var this_champion = $"%SessionWon".get_child(0)
	this_champion.insert_name()

func fake_new_score() -> Scores:
	return Scores.new({"player": {}})
	"""
	var info_player := InfoPlayer.new()
	var champ = InfoChampion.new()
	info_player.set_species(global.get_species(TheUnlocker.unlocked_elements["species"].keys()[randi()%4]))
	champ.player = info_player.to_dict()
	var fake_session = TheSession.new()
	champ.session_info = fake_session.to_dict()
	return champ
	"""

const FILEPATH ="user://hall_of_fame-%s-%s.json"

func store_new_entry(new_champion: Dictionary) -> void: 
	var minigame = new_champion["minigame"]
	var number_players = str(len(new_champion["players"]))
	var complete_filepath = FILEPATH % [minigame, number_players]
	var save_file = FileAccess.open(complete_filepath, FileAccess.READ_WRITE)
	if not save_file:
		save_file = FileAccess.open(complete_filepath, FileAccess.WRITE)
	# Serialize the data dictionary to JSON
	save_file.seek_end()
	save_file.store_line(JSON.new().stringify(new_champion))
	# Write the JSON to the file and save to disk
	save_file.close()

func get_hall_of_fame(last_score:Scores) -> Array:
	var minigame = last_score.minigame_name
	var number_players = str(len(last_score.players))
	var complete_filepath = FILEPATH % [minigame, number_players]
	return Utils.read_file_by_line(complete_filepath)
	
