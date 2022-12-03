tool
extends Gate
class_name PortalGate

export var linked_to_path : NodePath
export var tint := Color('#ff6600') setget set_tint
export var inverted := false setget set_inverted

func set_tint(v):
	tint = v
	if not is_inside_tree():
		yield(self, "ready")
	$RingPart.self_modulate = tint.lightened(0.3)
	$"%BottomRingPart".self_modulate = tint
	$"%Inside".modulate = tint
	$"%SpikeParticles2D".modulate = tint
	$"%ColoredParticles2D".modulate = tint
	
func set_inverted(v):
	inverted = v
	if inverted:
		$PortalEffect.scale.x = -1
		$"%Particles2D".scale.x = -1
		$"%ColoredParticles2D".scale.x = -1
		
func set_width(v: float) -> void:
	.set_width(v)
	if not is_inside_tree():
		yield(self, 'ready')
	$"%Particles2D".process_material.emission_box_extents.y = width / 550 * 250
	$"%ColoredParticles2D".process_material.emission_box_extents.y = width / 550 * 250
	$"%SpikeParticles2D".process_material.emission_box_extents.y = width / 550 * 250
	$"%Particles2D".amount = width / 550 * 8
	$"%ColoredParticles2D".amount = width / 550 * 8
	$"%SpikeParticles2D".amount = width / 550 * 8
	$"%Inside".scale.y = width / 550 * 4.5
	
func _on_PortalGate_crossed(sth, _self, trigger):
	if not trigger:
		return
		
	var destination = get_node(linked_to_path)
	if destination == null:
		return
		
	var vector = sth.global_position - global_position
	sth.global_position = destination.global_position + vector
	
	assert(traits.has_trait(sth, 'Tracked'))
	traits.get_trait(sth, 'Tracked').reset()
	
	if destination is Gate:
		destination.act_as_if_crossed_by(sth)

func is_linked() -> bool:
	return has_node(linked_to_path)
	
func enable() -> void:
	.enable()
	$PortalEffect.visible = true
	
func disable() -> void:
	.disable()
	$PortalEffect.visible = false
