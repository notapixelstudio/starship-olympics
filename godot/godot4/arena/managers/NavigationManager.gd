extends Node

@export var navigation_container : Node2D

var _queued_update := false

func _ready() -> void:
	Events.arena_ready.connect(_on_arena_ready)
	Events.navigation_zone_changed.connect(_on_navigation_zone_changed)

func _on_arena_ready() -> void:
	update_navigation_zones()
	
func _on_navigation_zone_changed(zone):
	if _queued_update:
		return
	_queued_update = true
	print('a navigation zone has changed... about to update navigation')
	# pessimistic
	update_navigation_zones.call_deferred()
	
func update_navigation_zones():
	# delete all navigation nodes already present, if any
	for child in navigation_container.get_children():
		child.free()
		
	# prepare zone for each layer
	var navigation_polygons = {
		'default': NavigationPolygon.new(),
		'holder': NavigationPolygon.new()
	}
	for zone_t in traits.get_all('NavigationZone'):
		var polygon = zone_t.get_polygon()
		var layers = zone_t.get_layers()
		var offset
		match zone_t.get_offset_type():
			'none':
				offset = 0
			'inset':
				offset = -100
			'outset':
				offset = 100
		var result = Geometry2D.offset_polygon(polygon, offset)
		for resulting_polygon in result:
			for layer in layers:
				navigation_polygons[layer].add_outline(resulting_polygon)
	
	for layer in navigation_polygons.keys():
		var navpoly = navigation_polygons[layer]
		NavigationServer2D.parse_source_geometry_data(navpoly)
		navpoly.make_polygons_from_outlines()
		var navregion = NavigationRegion2D.new()
		navregion.set_navigation_polygon(navpoly)
		var bitmask
		match(layer):
			'default':
				bitmask = 1
			'holder':
				bitmask = 2
		navregion.set_navigation_layers(bitmask)
		navigation_container.add_child(navregion)
	
	_queued_update = false
	
