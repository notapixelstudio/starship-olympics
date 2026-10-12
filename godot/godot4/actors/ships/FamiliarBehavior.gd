class_name FamiliarBehavior extends ActorBehavior
## Context helpers for behaviors that specifically need ships and familiars.

var familiar: Familiar
var owner_ship: Ship

func configure(host: Node2D, source: Node2D = null) -> void:
	super.configure(host, source)
	familiar = host as Familiar
	owner_ship = source as Ship
