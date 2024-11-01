@tool
extends Node2D

class_name PilotStats

const STAR_OFFSET = 128

@export var star_scene : PackedScene
@export var player : Player : get = get_player, set = set_player
@export var points := -1 : set = set_points
@export var new_points := 1 : set = set_new_points
@export var max_points := 3 : set = set_max_points

var new_y : set = change_y

func set_player(v: Player):
	player = v
	
func get_player() -> Player:
	return player

func set_points(v: int):
	points = v
	
func set_new_points(v:int):
	new_points = v
	
func set_max_points(v: int):
	max_points = v
	
func _ready() -> void:
	%Headshot.set_player(player)
	#for stats in $"%StatsContainer".get_children():
	#	stats.set_stats_value(str(player_stats.get(stats.key)))
	%Background.modulate = player.get_color()
	%WinnerOutline.modulate = player.get_color()
	%PlayerID.text = player.get_username()
	%PlayerID.modulate = player.get_color()
	
	_update_stars()
	
func _update_stars():
	# empty container
	for child in %StarsContainer.get_children():
		child.queue_free()
	
	for i in range(max_points):
		var point = star_scene.instantiate()
		
		point.position.x = 100 + i*STAR_OFFSET - max_points*STAR_OFFSET/2.0
		point.position.y = 68
		point.set_index(i)
		if i < points:
			point.set_scored(true)
			#point.perfect = points[i].perfect
			if i > points - new_points-1:
				point.set_just_scored(true)
		else:
			point.set_scored(false)
			point.set_perfect(false)
			
		%StarsContainer.add_child(point)

	
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
