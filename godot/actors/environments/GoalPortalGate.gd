tool
extends PortalGate
class_name GoalPortalGate

export var goal_owner : NodePath
var player = null
signal goal_done

var enabled := true

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
	else:
		set_player(null)
		
func set_player(v : InfoPlayer):
	player = v
	if player != null:
		$RingPart.self_modulate = player.species.color
		$'%PlayerLabel'.text = player.get_username().to_upper()
		$'%PlayerLabel'.modulate = player.species.color
	
func get_player():
	return player

# override
func _on_PortalGate_crossed(sth, _self, silent):
	if not enabled:
		return
		
	assert(traits.has_trait(sth, 'Owned'))
	var ball_player = sth.get_player()
	if sth is Ball and ball_player != null:
		assert(traits.has_trait(sth, 'Tracked'))
		if player != ball_player:
			emit_signal("goal_done", ball_player, self, sth.global_position, 1)
		sth.set_player(null) # ownership is reset whenever a goal is done
		
	._on_PortalGate_crossed(sth, _self, silent)

func _on_DefenseZone_body_entered(body):
	# disable pew ownership transfer if is the defender
	if body is Pew:
		body.disable_ownership_transfer()
		
func enable() -> void:
	enabled = true
	modulate = Color.white
	
func disable() -> void:
	enabled = false
	modulate = Color(1,1,1,0.3)
