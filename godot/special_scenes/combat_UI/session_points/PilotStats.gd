extends Node2D
tool

class_name PilotStats

var info: InfoPlayer

var new_position setget change_position
var max_points = 0

onready var stars = $Container/StarsContainer
onready var container = $Container
onready var stats_container = $Container/Stats/StatsContainer

var just_won: bool = false

func set_info(value: InfoPlayer):
	info = value
	var player_stats: PlayerStats = info.stats
	if container:
		container.get_node("Headshot").set_species(info.species)
		for stats in stats_container.get_children():
			stats.stats_value = str(player_stats.get(stats.key))
		stars.initialize(info.session_score, max_points, just_won)

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()

func get_player_info():
	return info
