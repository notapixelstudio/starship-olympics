class_name ArenaScope extends Scope

## Override to support the custom "ArenaScope" scope name and type hints for the returned type
static func get_scope(node: Node, scope_name: String = 'ArenaScope') -> ArenaScope:
	return super(node, scope_name)

func get_active_players() -> Array[Player]:
	return get_parent().get_active_players()
	
func get_teams() -> Dictionary[String,Array]:
	return get_parent().get_teams()
	
func get_ship_factory() -> ShipFactory:
	return %ShipFactory

signal battlefield_ready

signal spawn_request(object_to_spawn:Node, callback:Callable)
signal collision(ship:Ship, collider:CollisionObject2D, tag:String)

signal ship_died(player:Player)

signal time_gained(seconds:int)

signal item_obtained(item:Item, by_player:Player)
signal ship_disabled(ship:Ship)
