extends Area2D

export var goal_owner : NodePath
var player: InfoPlayer
var full := false

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())

func set_player(p: InfoPlayer) -> void:
	player = p
	modulate = player.species.color
	
func get_player() -> InfoPlayer:
	return player


func _on_SkullHole_body_entered(body):
	if not full and body is Ship and body.get_cargo().check_type('skull') and body.get_player() == player:
		body.get_cargo().empty()
		global.the_match.add_score(player.id, self.get_score())
		$Empty.visible = false
		$Full.visible = true
		full = true
		
func get_score():
	return 1
	
