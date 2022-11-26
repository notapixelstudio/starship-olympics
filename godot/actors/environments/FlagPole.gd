extends Area2D
class_name FlagPole

var flags := []

export var circuit_rotation_degrees := 0 setget set_circuit_rotation_degrees

export var goal_owner : NodePath
var player

func set_circuit_rotation_degrees(v):
	circuit_rotation_degrees = v
	$"%Circuit".rotation_degrees = circuit_rotation_degrees

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		
func set_player(v : InfoPlayer):
	player = v
	$'%PlayerLabel'.text = player.get_username().to_upper()
	$'%PlayerLabel'.modulate = player.species.color
	$Sprite.modulate = player.species.color
	$"%Circuit".modulate = player.species.color
	
func get_player():
	return player
	
func place_flag(flag):
	flags.append(flag)
	redraw_flags()
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Scoring")
	
func pop_flag():
	var result
	if len(flags) > 0:
		result = flags.pop_back()
		redraw_flags()
	if len(flags) == 0 and $AnimationPlayer.is_playing():
		$AnimationPlayer.play("RESET")
	return result
	
func redraw_flags():
	for i in $'%Flags'.get_child_count():
		$'%Flags'.get_child(i).visible = i < len(flags)
		
	if len(flags) > 0:
		recompute_animation_speed()
		
func recompute_animation_speed():
	$AnimationPlayer.playback_speed = len(flags)

func _process(delta):
	if player:
		global.the_match.add_score_to_team(player.team, delta*len(flags))

func _on_FlagPole_body_entered(body):
	if body is Ship:
		if body.get_player() == get_player() and body.get_cargo().check_type('flag') and len(flags) < 3:
			place_flag(body.get_cargo().give_holdable())
			
		if body.get_player() != get_player() and not body.has_cargo() and len(flags) > 0:
			var flag = pop_flag()
			body.get_cargo().load_holdable(flag)
	elif body is Ball and body.has_type('flag') and body.get_player() == get_player() and len(flags) < 3:
		body.get_parent().remove_child(body)
		place_flag(body)
