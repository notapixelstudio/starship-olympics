class_name FamiliarManager extends Trait2D
## Coordinates the familiars a ship leads. ItemManager adds it to a ship once it has familiars.
## Familiars outlive the ship, so anything kept here starts over with each new ship.

## Seconds the orbit rings have spun: one clock for all the ship's orbiters, so ring mates stay evenly spaced.
## It stops with the ship (pause, ship down).
var spin_time := 0.0

func validate():
	super.validate()
	assert(host is Ship)

func _physics_process(delta: float) -> void:
	spin_time += delta
