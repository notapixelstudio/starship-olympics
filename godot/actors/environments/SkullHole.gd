extends Area2D

export var goal_owner : NodePath
var player: InfoPlayer
var full := false

export var graphics_scale := 1.0

func _ready():
	$Empty.scale = graphics_scale*Vector2(1,1)
	$Full.scale = graphics_scale*Vector2(1,1)
	
	if has_node(goal_owner):
		var player_spawner = get_node(goal_owner)
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())

func set_player(p: InfoPlayer) -> void:
	player = p
	$Empty.modulate = player.species.color
	
func get_player() -> InfoPlayer:
	return player


func _on_SkullHole_body_entered(body):
	if full or body.is_queued_for_deletion():
		return
		
	var done := false
	if body is Ship and body.get_cargo().check_type('skull') and (body.get_player() == player or player == null):
		body.get_cargo().empty()
		done = true
	elif body is Ball and body.has_type('skull') and body.active: # active is needed to score points on newly created skulls
		body.queue_free()
		done = true
		
	if done:
		global.the_match.add_score(body.get_player().get_id(), self.get_score())
		global.arena.show_msg(body.get_player().species, 1, global_position)
		$Empty.visible = false
		$Full.visible = true
		full = true
		
		$RandomAudioStreamPlayer.play()
		
		$Tween.stop_all()
		$Tween.interpolate_property($Full, "modulate", $Full.modulate, body.get_player().species.color, 1.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
		$Tween.start()
		
func get_score():
	return 1
	
func is_full():
	return full
	
func is_empty():
	return not full
	
