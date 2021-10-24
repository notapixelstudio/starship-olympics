extends Node

const LOG_PATH = "user://log.ndjson"
var file : File

func datetime_to_str(datetime: Dictionary, fmt = "") -> String:
	# {"day":23,"dst":false,"hour":18,"minute":41,
	# "month":9,"second":55,"weekday":4,"year":2021}
	# FIXME replace with ISO dates
	var tz = OS.get_time_zone_info()
	var tz_hours = floor(tz.bias / 60)
	
	return "%s-%02d-%02dT%02d:%02d:%02d+%02d:00" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"], tz_hours]
	
func log_event(event: Dictionary, immediate: bool) -> void:
	#event.running_time = OS.get_ticks_usec()
	#event.datetime = datetime_to_str(OS.get_datetime(true))
	#event.local_datetime = datetime_to_str(OS.get_datetime())
	#event.execution_uuid = global.execution_uuid
	file.store_line(to_json(event))
	if immediate:
		file.flush() # WARNING writing to disk too often could hurt performance

func _init():
	# open the log file and go to the end
	file = File.new()
	file.open(LOG_PATH, File.WRITE)
	file.seek_end()
	
	#Events.connect('minigame_selected', self, '_on_minigame_selected')
	
	Events.connect('execution_started', self, '_on_execution_started')
	Events.connect('game_started', self, '_on_game_started')
	Events.connect('session_started', self, '_on_session_started')
	Events.connect('match_started', self, '_on_match_started')
	Events.connect('match_ended', self, '_on_match_ended')
	Events.connect('session_ended', self, '_on_session_ended')
	Events.connect('game_ended', self, '_on_game_ended')
	Events.connect('execution_ended', self, '_on_execution_ended')
	
func _on_minigame_selected(minigame: Minigame) -> void:
	log_event({
		'event_name': 'minigame_selected',
		'minigame': minigame.get_id()
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
	var event = global.the_game.to_log_dict()
	event.event_name = 'game_started'
	log_event(event, true)
	
func _on_game_ended() -> void:
	log_event({
		'event_name': 'game_ended',
		'game_uuid': global.the_game.get_uuid(),
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

func _on_match_ended() -> void:
	log_event({
		'event_name': 'match_ended',
		'duration_ms': OS.get_ticks_msec() - match_started_ms
	}, true)
