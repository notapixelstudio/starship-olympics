extends Node2D
tool

class_name PilotStats

export var player_info : Resource setget set_info # InfoPlayer

var new_position setget change_position

onready var container = $Container
onready var stats_container = $Container/Stats/StatsContainer

func set_info(value: InfoPlayer):
	player_info = value
	if container:
		$Label.text = str(player_info.session_score)
		container.get_node("Headshot").set_species(player_info.species_template)
		for stats in stats_container.get_children():
			stats.stats_value = str(player_info.get(stats.key))

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		print("we should change from here: ", position, " to here: ", new_position)
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()

func get_player_info():
	return player_info