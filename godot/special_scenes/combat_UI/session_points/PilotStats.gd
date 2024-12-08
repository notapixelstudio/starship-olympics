@tool
extends Node2D

class_name PilotStats

const ICON_OFFSET = 128

@export var session_point_icon_scene : PackedScene
@export var player : Player : get = get_player, set = set_player
@export var max_points := 3 : set = set_max_points
@export var session : Session : set = set_session

var new_y : set = change_y

func set_player(v: Player):
	player = v
	
func get_player() -> Player:
	return player
	
func set_max_points(v) -> void:
	max_points = v

func set_session(v:Session) -> void:
	session = v
	
func _ready() -> void:
	redraw()
	
func redraw() -> void:
	%Headshot.set_player(player)
	#for stats in $"%StatsContainer".get_children():
	#	stats.set_stats_value(str(player_stats.get(stats.key)))
	%Background.modulate = player.get_color()
	%WinnerOutline.modulate = player.get_color()
	%PlayerID.text = player.get_username()
	%PlayerID.modulate = player.get_color()
	
	update_score()
	
func update_score():
	# empty container
	for child in %IconContainer.get_children():
		child.queue_free()
		
	var score = _compute_score()
	
	for i in range(max_points):
		var icon = session_point_icon_scene.instantiate()
		
		icon.position.x = 100 + i*ICON_OFFSET - max_points*ICON_OFFSET/2.0
		icon.position.y = 68
		_update_icon(icon, i, score)
		
		%IconContainer.add_child(icon)

func _compute_score():
	return 1 if session.is_winner(player.get_team()) else 0
	# pilot_stats.set_new_points(1 if player.get_team() in match_winners else 0)
	

func _update_icon(icon, i, points) -> void:
	icon.set_index(i)
	if i < points:
		icon.set_scored(true)
		#icon.perfect = points[i].perfect
		#if i > points - new_points-1:
		#	icon.set_just_scored(true)
	else:
		icon.set_scored(false)
		icon.set_perfect(false)
	
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
	%AnimationPlayer.play("Victory")
	z_index = 210 + floor(position.y/10.0) # Y sorting, sort of!
