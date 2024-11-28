extends Node

@export var duration := 0.5
@export var pitch_step := 0.1
var _team_data := {}

func _ready():
	Events.team_ready.connect(_on_team_ready)
	Events.sth_collected.connect(_on_sth_collected)
	
func _on_team_ready(team, members) -> void:
	# add a new team
	var timer = Timer.new()
	add_child(timer) # must be in the scene tree
	_team_data[team] = {
		'id': team,
		'pitch_scale': 1.0,
		'timer': timer
	}
	# reset pitch scale on timeout
	timer.timeout.connect(func(): _team_data[team]['pitch_scale'] = 1.0)
	
func _on_sth_collected(collector, collectee):
	if not collector is Ship:
		return
		
	var sfx_player = collectee.get_sfx_player()
	var team = _team_data[collector.get_team()]
	sfx_player.pitch_scale = team['pitch_scale']
	SoundEffects.play(sfx_player)
	team['pitch_scale'] += pitch_step
	team['timer'].stop()
	team['timer'].start()
