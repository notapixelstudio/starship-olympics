class_name ArenaScope extends Scope

## Override to support the custom "ArenaScope" scope name and type hints for the returned type
static func get_scope(node: Node, scope_name: String = 'ArenaScope') -> ArenaScope:
	return super(node, scope_name)

func get_ship_factory() -> ShipFactory:
	return %ShipFactory
