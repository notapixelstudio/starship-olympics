class_name FamiliarTrait extends Trait2D
## A behaviour acting on its Familiar (the host). The familiar's ship comes and goes, so it is read live.

var familiar: Familiar
## The ship leading the chain, or null while it is down (movements idle so the familiar coasts).
var owner_ship: Ship:
	get: return familiar.get_owner_ship()

func validate():
	super.validate()
	assert(host is Familiar)

func _ready() -> void:
	super._ready()
	familiar = get_host()
