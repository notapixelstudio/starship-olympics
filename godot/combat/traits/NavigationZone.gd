extends Trait

export (String, 'none', 'inset', 'outset') var offset_type = 'none'
export var layers := [] # of Strings

func validate():
	.validate()
	assert(host.has_method('get_polygon'))
	
func get_polygon():
	return host.get_polygon()
	Geometry
	
func get_offset_type() -> float:
	return offset_type

func get_layers() -> Array:
	return layers
