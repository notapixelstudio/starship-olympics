extends Node

const LOG_PATH ="user://log.ndjson"
var file : File

func log_event(event: Dictionary, immediate: bool) -> void:
	#event.running_time = OS.get_ticks_usec()
	#event.datetime = OS.get_datetime(true)
	#event.local_datetime = OS.get_datetime()
	file.store_line(to_json(event))
	if immediate:
		file.flush() # WARNING writing to disk too often could hurt performance

func _ready():
	# open the log file and go to the end
	file = File.new()
	file.open(LOG_PATH, File.READ_WRITE)
	file.seek_end()
	
	Events.connect('minigame_selected', self, '_on_minigame_selected')
	
	Events.connect('session_started', self, '_on_session_started')
	Events.connect('match_started', self, '_on_match_started')
	Events.connect('match_ended', self, '_on_match_ended')
	
func _on_minigame_selected(minigame: Minigame) -> void:
	log_event({
		'event_name': 'minigame_selected',
		'minigame': minigame.get_id()
	}, true)

func _on_session_started() -> void:
	log_event({
		'event_name': 'session_started'
	}, true)
	
func _on_match_started() -> void:
	log_event({
		'event_name': 'match_started'
	}, true)

func _on_match_ended() -> void:
	log_event({
		'event_name': 'match_ended'
	}, true)
