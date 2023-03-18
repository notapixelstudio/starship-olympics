extends Area2D

export var goal_owner : NodePath
var player

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Line2D.points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	
func set_player(v : InfoPlayer):
	player = v
	$'%PlayerLabel'.text = player.get_username().to_upper()
	$'%PlayerLabel'.modulate = player.species.color
	$Polygon2D.modulate = player.species.color
	$Line2D.modulate = player.species.color
	
func get_player():
	return player

var old_scoring := false
func _process(delta):
	var scoring := false
	if player:
		for body in get_overlapping_bodies():
			if body is Ball:
				scoring = true
				global.the_match.add_score_to_team(player.team, delta)
			elif body is Ship:
				var holdable = body.get_cargo().get_holdable()
				
				if holdable != null and holdable is Ball:
					global.the_match.add_score_to_team(player.team, delta)
					scoring = true
	
	if scoring == true and old_scoring == false:
		$AnimationPlayer.play("Scoring")
	if scoring == false and old_scoring == true:
		$AnimationPlayer.play_backwards("Scoring")
		
	old_scoring = scoring
