@tool
extends Node2D

class_name PilotStats

@export var player : Player : get = get_player, set = set_player

var new_position : set = change_position
var max_session_score := 1 # default: standalone

func set_player(v: Player):
	player = v
	if not is_inside_tree():
		await self.ready
	%Headshot.set_player(player)
	#for stats in $"%StatsContainer".get_children():
	#	stats.set_stats_value(str(player_stats.get(stats.key)))
	%Background.modulate = player.get_color()
	%WinnerOutline.modulate = player.get_color()
	%PlayerID.text = player.get_username()
	%PlayerID.modulate = player.get_color()
	
func get_player() -> Player:
	return player

func set_session_score(session_score: int, just_won:= false):
	if not is_inside_tree():
		await self.ready
	%StarsContainer.initialize(session_score, max_session_score, just_won)
	
func change_position(new_value):
	new_position = new_value
	if position != new_position:# and not $Tween.is_active():
		#$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
		#	Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		#$Tween.start()
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(self, 'position', new_position, 0.5)
		#await tween.finished

func celebrate():
	$AnimationPlayer.play("Victory")
	z_index = 1
