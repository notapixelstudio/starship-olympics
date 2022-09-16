extends Node2D
@tool

class_name PilotStats

var info: InfoPlayer

var new_position :
	get:
		return new_position # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of change_position
var max_points = 0

var just_won: bool = false

func set_info(value: InfoPlayer):
	info = value
	var player_stats: PlayerStats = info.stats
	$"%Headshot".set_species(info.species)
	for stats in $"%StatsContainer".get_children():
		stats.set_stats_value(str(player_stats.get(stats.key)))
	$"%StarsContainer".initialize(info.session_score, max_points, just_won)
	$Background.modulate = info.get_color()
	$WinnerOutline.modulate = info.get_color()

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()

func get_player_info():
	return info

func celebrate():
	$AnimationPlayer.play("Victory")
	
