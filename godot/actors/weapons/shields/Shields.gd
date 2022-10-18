extends Node2D

signal hit(by)

var owner_ship : Ship

export var layers := 2
export var sectors := [2, 4]
export var internal_radius := 100.0
export var radii := [120.0, 90.0]
export var angles := [0.0, PI/2]
export var angle_speeds := [-PI/5, PI/3]
export var padding := 0.0
export var layer_scene : PackedScene

var layer_children := []

func _ready():
	owner_ship = get_parent()
	
	var r := internal_radius
	for i in range(layers):
		var layer = layer_scene.instance()
		layer.rotation = angles[i]
		layer.angle_speed = angle_speeds[i]
		layer.sectors = sectors[i]
		layer.inner_radius = r
		r += radii[i]
		layer.outer_radius = r
		r += padding
		add_child(layer)
		layer_children.append(layer)
		layer.connect('body_shape_entered', self, '_on_Area2D_body_shape_entered', [layer])
		
func _on_Area2D_body_shape_entered(body_id, body, body_shape, local_shape, layer):
	if body is Bomb and body.get_owner_ship() != owner_ship or body is Bullet:
		body.dissolve()
		body.queue_free()
		
		var local_shape_owner_id = layer.shape_find_owner(local_shape)
		var sector = layer.shape_owner_get_owner(local_shape_owner_id)
		
		sector.down()
		
		emit_signal('hit', body)

func up(type) -> bool:
	var done := false
	
	match type:
		'shields':
			# bring up a shield in each of the nearest two available sectors
			var amount := 2
			for layer in layer_children:
				for sector in layer.get_sectors():
					if sector.is_available():
						sector.up('shield')
						done = true
						amount -= 1
						if amount == 0:
							break
				if done and amount == 0:
					break
					
		'skin', 'shield':
			# bring up a single skin or shield in the nearest available sector
			for layer in layer_children:
				for sector in layer.get_sectors():
					if sector.is_available():
						sector.up(type)
						done = true
						break
				if done:
					break
					
			# overwrite shield sectors with skin if no available space was found
			if type == 'skin' and not done:
				for layer in layer_children:
					for sector in layer.get_sectors():
						if sector.type == 'shield':
							sector.up('skin')
							done = true
							break
					if done:
						break
						
		'plate':
			# bring up a plate in the nearest available sector of a layer with no plates already
			for layer in layer_children:
				if layer.has_plate():
					continue
				for sector in layer.get_sectors():
					if sector.is_available():
						sector.up('plate')
						done = true
						break
				if done:
					break
					
			# overwrite shield sectors if no available space was found
			if not done:
				for layer in layer_children:
					if layer.has_plate():
						continue
					for sector in layer.get_sectors():
						if sector.type == 'shield':
							sector.up('plate')
							done = true
							break
					if done:
						break
						
			# overwrite skin sectors if no available space was found
			if not done:
				for layer in layer_children:
					if layer.has_plate():
						continue
					for sector in layer.get_sectors():
						if sector.type == 'skin':
							sector.up('plate')
							done = true
							break
					if done:
						break
			
	if done:
		$AudioStreamPlayer2D.play()
		
	return done

func down():
	for layer in layer_children:
		layer.down()
		
func switch_off():
	for layer in layer_children:
		layer.switch_off()
		
func _process(delta):
	rotation = -get_parent().global_rotation
	
