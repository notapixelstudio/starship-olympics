extends Node

const LOG_PATH ="user://log.ndjson"
var file : File

func log_event(event: Dictionary, immediate: bool) -> void:
	#event.running_time = OS.get_ticks_usec()
	#event.datetime = datetime_to_str(OS.get_datetime(true))
	#event.local_datetime = datetime_to_str(OS.get_datetime())
	#event.execution_uuid = global.execution_uuid
	event.timestamp_local = Time.get_datetime_string_from_system(false, true)
	event.timestamp = Time.get_datetime_string_from_system(true, true)

	event.running_time = OS.get_ticks_usec()
	file.store_line(to_json(event))
	if immediate:
		file.flush() # WARNING writing to disk too often could hurt performance

func _init():
	
	# open the log file and go to the end
	file = File.new()
	var error = file.open(LOG_PATH, File.READ_WRITE)
	var filesize_in_kb = file.get_len()/float(1024)
	print("Log file is {size} KB".format({"size":filesize_in_kb}))
	if filesize_in_kb > 200:
		file.close()
		var d = Directory.new()
		print("Will remove the file because too big")
		error = d.remove(LOG_PATH)
		error = ERR_FILE_NOT_FOUND
	if error == ERR_FILE_NOT_FOUND :
		error = file.open(LOG_PATH, File.WRITE_READ)
	if error == OK:
		file.seek_end()
	else:
		print("We could not open a log file")
	
	# events connected and logged
	Events.connect('execution_started', self, '_on_execution_started')
	Events.connect('game_started', self, '_on_game_started')
	Events.connect('session_started', self, '_on_session_started')
	Events.connect('match_started', self, '_on_match_started')
	Events.connect('match_ended', self, '_on_match_ended')
	Events.connect('session_ended', self, '_on_session_ended')
	Events.connect('game_ended', self, '_on_game_ended')
	Events.connect('execution_ended', self, '_on_execution_ended')
	Events.connect('draft_ended', self, '_on_draft_ended')

func _on_draft_ended(choices:Dictionary, hand:Array) -> void:
	var card_ids := []
	for card in hand:
		card_ids.append((card as DraftCard).get_id())
	log_event({
		'event_name': 'draft_ended',
		'draft_choices': choices,
		'hand': card_ids
	}, true)
	
func _on_minigame_selected(picked_card: DraftCard) -> void:
	log_event({
		'event_name': 'minigame_selected',
		'card': picked_card.get_id(),
		'minigame': picked_card.get_minigame().get_id()
	}, true)

var execution_started_ms : int
func _on_execution_started() -> void:
	execution_started_ms = OS.get_ticks_msec()
	log_event({
		'event_name': 'execution_started'
	}, true)
	
func _on_execution_ended() -> void:
	log_event({
		'event_name': 'execution_ended',
		'duration_ms': OS.get_ticks_msec() - execution_started_ms
	}, true)
	
	
var game_started_ms : int
func _on_game_started() -> void:
	game_started_ms = OS.get_ticks_msec()
	var event = global.the_game.to_dict()
	event.event_name = 'game_started'
	log_event(event, true)
	
func _on_game_ended() -> void:
	log_event({
		'event_name': 'game_ended',
		'game_uuid': global.the_game.get_uuid(),
		'game_number': global.game_number,
		'duration_ms': OS.get_ticks_msec() - game_started_ms
	}, true)
	
	
var session_started_ms : int
func _on_session_started() -> void:
	session_started_ms = OS.get_ticks_msec()
	
	log_event({
		'event_name': 'session_started'
	}, true)
	
func _on_session_ended() -> void:
	log_event({
		'event_name': 'session_ended',
		'duration_ms': OS.get_ticks_msec() - session_started_ms
	}, true)
	
	
var match_started_ms : int
func _on_match_started() -> void:
	match_started_ms = OS.get_ticks_msec()
	
	log_event({
		'event_name': 'match_started'
	}, true)

func _on_match_ended(match_dict: Dictionary) -> void:
	log_event({
		'event_name': 'match_ended',
		'duration_ms': OS.get_ticks_msec() - match_started_ms
	}, true)
