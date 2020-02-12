extends Node2D
tool

class_name PilotStats

var info setget set_info # PlayerStats

var new_position setget change_position
var max_points = 0

onready var stars = $Container/StarsContainer
onready var container = $Container
onready var stats_container = $Container/Stats/StatsContainer

var just_won: bool = false

func set_info(value):
	# value is PlayerStats
	info = value
	if container:
		container.get_node("Headshot").set_species(info.species)
		for stats in stats_container.get_children():
			stats.stats_value = str(info.get(stats.key))
		stars.initialize(info.session_score, max_points, just_won)

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		print_debug("we should change from here: ", position, " to here: ", new_position)
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()

func get_player_info():
	return info
