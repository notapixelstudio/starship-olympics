@tool
extends Node2D

class_name PilotStats

@export var player : Player : get = get_player, set = set_player
@export var session_score := -1 : set = set_session_score
@export var max_session_score := 3 : set = set_max_session_score

var new_y : set = change_y

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

func set_session_score(v: int):
	session_score = v
	if not is_inside_tree():
		await self.ready
	%StarsContainer.initialize(session_score, max_session_score, false)
	
func set_max_session_score(v: int):
	max_session_score = v
	
func change_y(new_value):
	new_y = new_value
	if position.y != new_y:# and not $Tween.is_active():
		#$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
		#	Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		#$Tween.start()
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(self, 'position:y', new_y, 0.5)
		#await tween.finished

func celebrate():
	$AnimationPlayer.play("Victory")
	z_index = 1
