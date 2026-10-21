extends Hat
class_name Baton

func clone_as_new() -> Cargo:
	var clone := super.clone_as_new()
	clone.passable = false # a fresh hand-off always starts not-passable: do your own lap first
	return clone
