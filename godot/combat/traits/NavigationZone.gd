extends Trait

@export_enum('none', 'inset', 'outset') var offset_type : String = 'none'
@export var layers := ['default', 'holder'] # of Strings

func validate():
	super.validate()
	assert(host.has_method('get_polygon'))
	
func get_polygon():
	return host.get_polygon()
	
func get_offset_type() -> String:
	return offset_type

func get_layers() -> Array:
	return layers
