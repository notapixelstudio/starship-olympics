tool
extends PortalGate
class_name GoalPortalGate

export var goal_owner : NodePath
var player
signal goal_done

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		
func set_player(v : InfoPlayer):
	player = v
	$RingPart.self_modulate = player.species.color
	$'%PlayerLabel'.text = player.get_username().to_upper()
	$'%PlayerLabel'.modulate = player.species.color
	
func get_player():
	return player

# override
func _on_PortalGate_crossed(sth, _self):
	assert(traits.has_trait(sth, 'Owned'))
	var ball_player = sth.get_player()
	if sth is Ball and ball_player != null and player != ball_player:
		assert(traits.has_trait(sth, 'Tracked'))
		emit_signal("goal_done", sth.get_player(), self, sth.global_position)
		sth.set_player(null) # ownership is reset whenever a goal is done
		
	._on_PortalGate_crossed(sth, _self)
