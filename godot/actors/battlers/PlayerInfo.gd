extends Position2D

export var target_path: NodePath = @".."

export var primary_texture : Texture
export var secondary_texture : Texture

onready var target = get_node(target_path) as Node2D if has_node(target_path) else null
onready var player_id = $Scaled/Colored/PlayerID
onready var target_entity = ECM.E(target)

func _ready():
	if target.info_player:
		player_id.text = tr(target.info_player.id)
	$Scaled/Colored.modulate = target.species_template.color
	if target.species_template.id >= 100 and target.info_player.team:
		$Scaled/Colored/Circle.set_texture(secondary_texture)
	else:
		$Scaled/Colored/Circle.set_texture(primary_texture)
		
	update_scale()
	update_rotation()
	update_crown()
	
func _enter_tree():
	if target:
		update_rotation()
		
	if target_entity:
		update_crown()
	
func _process(delta):
	if target:
		update_rotation()
		
	if target_entity:
		update_crown()
		
	update_scale()
	
func update_scale():
	scale = target.arena.camera.zoom
	
func update_rotation():
	rotation = -target.rotation
	
func update_crown():
	$Scaled/Crown.set_visible(target_entity.has('Royal'))
	