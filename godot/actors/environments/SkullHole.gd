extends Area2D

@export var goal_owner : NodePath
var player: InfoPlayer
var full := false

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		await player_spawner.player_assigned
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
	if body is Ship and body.get_cargo().check_type('skull') and body.get_player() == player:
		body.get_cargo().is_empty()
		done = true
	elif body is Ball and body.has_type('skull') and body.active: # active is needed to score points checked newly created skulls
		body.queue_free()
		done = true
		
	if done:
		global.the_match.add_score(player.id, self.get_score())
		global.arena.show_msg(player.species, 1, global_position)
		$Empty.visible = false
		$Full.visible = true
		full = true
		
		$RandomAudioStreamPlayer.play()
		
		$Tween.stop_all()
		$Tween.interpolate_property($Full, "modulate", $Full.modulate, player.species.color, 1.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
		$Tween.start()
		
func get_score():
	return 1
	
