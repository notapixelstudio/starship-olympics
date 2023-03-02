tool
extends StaticBody2D

func _ready():
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func refresh():
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	var polygon = gshape.to_PoolVector2Array()
	var line = gshape.to_closed_PoolVector2Array()
	$"%SuperOverlay".polygon = polygon
	$"%Top".polygon = polygon
	$"%Overlay".polygon = polygon
	$"%Outline".points = line
	$"%Bottom".points = $"%Outline".points
	$"%OverlapArea/CollisionPolygon2D".polygon = polygon
	$CollisionPolygon2D.polygon = polygon
	$"%Top".texture_offset = gshape.get_extents()

func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _on_OverlapArea_body_entered(body):
	if body.has_method('set_phasing_in_prevented'):
		body.set_phasing_in_prevented(true)
		
	# trigger rockets
	if body.has_method('detonate'):
		body.detonate()
		

func _on_OverlapArea_body_exited(body):
	if body.has_method('set_phasing_in_prevented') and body.has_method('phase_in'):
		body.set_phasing_in_prevented(false)
		body.phase_in()

